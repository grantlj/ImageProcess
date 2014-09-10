function phow_caltech101()
% PHOW_CALTECH101 Image classification in the Caltech-101 dataset
%   This program demonstrates how to use VLFeat to construct an image
%   classifier on the Caltech-101 data. The classifier uses PHOW
%   features (dense SIFT), spatial histograms of visual words, and a
%   Chi2 SVM. To speedup computation it uses VLFeat fast dense SIFT,
%   kd-trees, and homogeneous kernel map. The program also
%   demonstrates VLFeat PEGASOS SVM solver, although for this small
%   dataset other solvers such as LIBLINEAR can be more efficient.
%   
%   稠密SIFT和分布直方图 + SVM来分类

%   By default 15 training images are used, which should result in
%   about 64% performance (a good performance considering that only a
%   single feature type is being used).
%
%   Call PHOW_CALTECH101 to train and test a classifier on a small
%   subset of the Caltech-101 data. Note that the program
%   automatically downloads a copy of the Caltech-101 data from the
%   Internet if it cannot find a local copy.
%
%   Edit the PHOW_CALTECH101 file to change the program configuration.
%
%   To run on the entire dataset change CONF.TINYPROBLEM to FALSE.
%
%   The Caltech-101 data is saved into CONF.CALDIR, which defaults to
%   'data/caltech-101'. Change this path to the desired location, for
%   instance to point to an existing copy of the Caltech-101 data.
%   
%    更改CONF中的CALDIR我们可以实现训练自己的集合
%   The program can also be used to train a model on custom data by
%   pointing CONF.CALDIR to it. Just create a subdirectory for each
%   class and put the training images there. Make sure to adjust
%   CONF.NUMTRAIN accordingly.（NUMTRAIN也要跟着变）
%
%   Intermediate files are stored in the directory CONF.DATADIR. All
%   such files begin with the prefix CONF.PREFIX, which can be changed
%   to test different parameter settings without overriding previous
%   results.   %中间文件
%
%   The program saves the trained model in
%   <CONF.DATADIR>/<CONF.PREFIX>-model.mat. This model can be used to
%   test novel images independently of the Caltech data. %训练过的结果保存位置
%
%     load('data/baseline-model.mat') ; # change to the model path
%     label = model.classify(model, im) ;
%

% Author: Andrea Vedaldi

% Copyright (C) 2011-2013 Andrea Vedaldi
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

conf.calDir = 'data/caltech-101' ;
conf.dataDir = 'data/' ;
conf.autoDownloadData = true ;
conf.numTrain = 15 ;                                                        %训练15张
conf.numTest = 15 ;                                                         %测试15张
conf.numClasses = 102 ;
conf.numWords = 600 ;
conf.numSpatialX = [2 4] ;
conf.numSpatialY = [2 4] ;
conf.quantizer = 'kdtree' ;  %KD树  一种用于SIFT算法中必备的东西。。。？
conf.svm.C = 10 ;

conf.svm.solver = 'sdca' ;
%conf.svm.solver = 'sgd' ;
%conf.svm.solver = 'liblinear' ;

conf.svm.biasMultiplier = 1 ;
conf.phowOpts = {'Step', 3} ;
conf.clobber = true ;
conf.tinyProblem = true ;
conf.prefix = 'baseline' ;
conf.randSeed = 1 ;

if conf.tinyProblem
  conf.prefix = 'tiny' ;
  conf.numClasses = 5 ;
  conf.numSpatialX = 2 ;
  conf.numSpatialY = 2 ;
  conf.numWords = 300 ;
  conf.phowOpts = {'Verbose', 2, 'Sizes', 7, 'Step', 5} ;
end

conf.vocabPath = fullfile(conf.dataDir, [conf.prefix '-vocab.mat']) ;
conf.histPath = fullfile(conf.dataDir, [conf.prefix '-hists.mat']) ;
conf.modelPath = fullfile(conf.dataDir, [conf.prefix '-model.mat']) ;
conf.resultPath = fullfile(conf.dataDir, [conf.prefix '-result']) ;

randn('state',conf.randSeed) ;
rand('state',conf.randSeed) ;
vl_twister('state',conf.randSeed) ;

% --------------------------------------------------------------------
%                                            Download Caltech-101 data
% --------------------------------------------------------------------

if ~exist(conf.calDir, 'dir') || ...
   (~exist(fullfile(conf.calDir, 'airplanes'),'dir') && ...
    ~exist(fullfile(conf.calDir, '101_ObjectCategories', 'airplanes')))
  if ~conf.autoDownloadData
    error(...
      ['Caltech-101 data not found. ' ...
       'Set conf.autoDownloadData=true to download the required data.']) ;
  end
  vl_xmkdir(conf.calDir) ;
  calUrl = ['http://www.vision.caltech.edu/Image_Datasets/' ...
    'Caltech101/101_ObjectCategories.tar.gz'] ;
  fprintf('Downloading Caltech-101 data to ''%s''. This will take a while.', conf.calDir) ;
  untar(calUrl, conf.calDir) ;
end

if ~exist(fullfile(conf.calDir, 'airplanes'),'dir')
  conf.calDir = fullfile(conf.calDir, '101_ObjectCategories') ;
end

% --------------------------------------------------------------------
%                                                           Setup data
% --------------------------------------------------------------------
classes = dir(conf.calDir) ;
classes = classes([classes.isdir]) ;                                                     %这个classes是得到conf文件夹下面的类别
classes = {classes(3:conf.numClasses+2).name} ;                                        

% 我们的demo程序这里只取了几类：BACKGROUND,
% FACE LEOPARDS和motorbike
images = {} ;                                                                              %保存所有文件的路径+名称（所有类别）                       
imageClass = {} ;                                                                          %保存说所有文件的类别1、2、3、4、5
for ci = 1:length(classes)
   %IMS是临时变量
  ims = dir(fullfile(conf.calDir, classes{ci}, '*.jpg'))' ;                                %得到每个类别下面的所有文件和对应信息
  ims = vl_colsubset(ims, conf.numTrain + conf.numTest) ;                                  %选择特定的行数（特定个数的文件 每种前30个，前15是train，后15是test）
  ims = cellfun(@(x)fullfile(classes{ci},x),{ims.name},'UniformOutput',false) ;            %文件信息转文件路径+名称
  images = {images{:}, ims{:}} ;                                                           %images保存的是所有种类的所有文件路径+名称，这里是一个叠加的操作
  imageClass{end+1} = ci * ones(1,length(ims)) ;                                           %每一张退片给一个特定的序号对应类别 第一类就是1，第N类就是N，依次类推
end
selTrain = find(mod(0:length(images)-1, conf.numTrain+conf.numTest) < conf.numTrain) ;     %selTrain把每个种类里用来train的图片序数（images里的）挑出来 这里用mod取余数的方法 赞
selTest = setdiff(1:length(images), selTrain) ;                                            %seldiff做的是同样是事，把待测试的图片序数取出 setdiff取差集！
imageClass = cat(2, imageClass{:}) ;                                                       %imageClass全部展开成一个vector 1,1,1,1,....2,2,2,2,2....5,5,5,5,5 每种30个
% 
% 信息全部存入模型，待用
model.classes = classes ;                                                   %1*5个cell 类型字符串
model.phowOpts = conf.phowOpts ;                                            %Dense-SIFT的固有参数 
model.numSpatialX = conf.numSpatialX ;                                      
model.numSpatialY = conf.numSpatialY ;
model.quantizer = conf.quantizer ;
model.vocab = [] ;                                                         %词典？
model.w = [] ;
model.b = [] ;
model.classify = @classify ;

% --------------------------------------------------------------------
%                                                     Train
%                                                     vocabulary（训练词典）
% --------------------------------------------------------------------

if ~exist(conf.vocabPath) || conf.clobber                                   %如果检测到我们还没做过训练(这里为了观察程序行为 将conf.clobber设置成了true）

  % Get some PHOW descriptors to train the dictionary
  selTrainFeats = vl_colsubset(selTrain, 30) ;                              %那就训练吧！！！！ 
  %colsubset的意思是随机选若干列数，这里是从训练集里面随机选30列 刚才总的训练集是是5*15=75哦
  descrs = {} ;
  %for ii = 1:length(selTrainFeats)
  for ii = 1:length(selTrainFeats)
    im = imread(fullfile(conf.calDir, images{selTrainFeats(ii)})) ;         %依次读取训练集
    im = standarizeImage(im) ;                                              %预处理 标准化图像
    [drop, descrs{ii}] = vl_phow(im, model.phowOpts{:}) ;                   %用设置好的phow参数来得到当前图像的vl_phow结果
    %{
      vl_phow是这里的核心函数。。。
      官方文档：http://www.vlfeat.org/matlab/vl_phow.html
      根据文档说明：
      
      drop是一个4行 M列的矩阵 描述M个DSIFT特征子的信息
      第一行和第二行是每个特征子的坐标
      第三行是每个特征子的对比度？由颜色强度决定
      第四行是每个特征子的大小（几个二进制位）
      
      descrs是每一个特征子的vector信息 一共128行 M列 每一列是一个128维度的向量
      至于为什么是128维，这个是不同模糊程度下的SIFT Vector组合得到的？
      
      总之Drop保存descrs的辅助信息 descrs保存每个DSIFT算子的详细信息
    %}
  end
  
   %全部二维化 保存在一个大mat里面 还是128列 30*sigma(Mi)行
  descrs = vl_colsubset(cat(2, descrs{:}), 10e4) ;                         
  descrs = single(descrs) ;  %变成单精度
 
  
  % Quantize the descriptors to get the visual words
  %Kmeans聚类 得到vocab
  
  %{
   vl_kmeans是这里的另外一个重要函数
   官方文档：http://www.vlfeat.org/matlab/vl_kmeans.html
   我们这里做的事情是把所有 DSIFT描述子分成300个不同的类别
   最终我们得到了一个128行 300列的 Mat
   每一列是表示每一类的---质心---的位置
  
  http://blog.csdn.net/v_july_v/article/details/8203674/
  k-means kd-tree sift关系特征详解
  总之就是帮助你索引和归类 某一个SIFT特征在 vocab的位置的 一种数据结构
  
  %}
  vocab = vl_kmeans(descrs, conf.numWords, 'verbose', 'algorithm', 'elkan', 'MaxNumIterations', 50) ;
  save(conf.vocabPath, 'vocab') ;
else
  load(conf.vocabPath) ;
end

model.vocab = vocab ;

if strcmp(model.quantizer, 'kdtree')
  model.kdtree = vl_kdtreebuild(vocab) ;
end

% --------------------------------------------------------------------
%                                           Compute spatial histograms
% --------------------------------------------------------------------

if ~exist(conf.histPath) || conf.clobber
  hists = {} ;
 for ii = 1:length(images)           %注意这里是所有的图像 5*30=150张！！！！！！！！！！！
  % for ii = 1:length(images)
    fprintf('Processing %s (%.2f %%)\n', images{ii}, 100 * ii / length(images)) ;
    im = imread(fullfile(conf.calDir, images{ii})) ;
    hists{ii} = getImageDescriptor(model, im);                                    %得到HIST直方图辅助运算
  end

  hists = cat(2, hists{:}) ;
  save(conf.histPath, 'hists') ;                                                  %所有图的SIFT归类信息
else
  load(conf.histPath) ;
end

% --------------------------------------------------------------------
%                                                  Compute feature map
% --------------------------------------------------------------------

psix = vl_homkermap(hists, 1, 'kchi2', 'gamma', .5) ;  %这一步是把hists直方图做一次变换 供给chi2 SVM核函数使用

% --------------------------------------------------------------------
%                                                            Train
%                                                            SVM（用不同的训练集的SIFT直方图
%                                                           和已知的训练集对应类别来训练SVM。
% --------------------------------------------------------------------

if ~exist(conf.modelPath) || conf.clobber
  switch conf.svm.solver
    case {'sgd', 'sdca'}                                                     %判断SVM分类的类型
      lambda = 1 / (conf.svm.C *  length(selTrain)) ;                        %学习效率？？？
      w = [] ;
      for ci = 1:length(classes)
        perm = randperm(length(selTrain)) ;                                  %随机打乱训练队列。
        fprintf('Training model for class %s\n', classes{ci}) ;
        y = 2 * (imageClass(selTrain) == ci) - 1 ;                           %y就是那个 到底是哪个class的标记啊
        [w(:,ci) b(ci) info] = vl_svmtrain(psix(:, selTrain(perm)), y(perm), lambda, ...         %用训练集来训练SVM分类器 维度：SIFT的直方图 每种不同的SIFT对应一个维度；
          'Solver', conf.svm.solver, ...
          'MaxNumIterations', 50/lambda, ...
          'BiasMultiplier', conf.svm.biasMultiplier, ...
          'Epsilon', 1e-3);
      end

    case 'liblinear'                                             %非sgd，sdca分类法
      svm = train(imageClass(selTrain)', ...
                  sparse(double(psix(:,selTrain))),  ...
                  sprintf(' -s 3 -B %f -c %f', ...
                          conf.svm.biasMultiplier, conf.svm.C), ...
                  'col') ;
      w = svm.w(:,1:end-1)' ;
      b =  svm.w(:,end)' ;
  end

  model.b = conf.svm.biasMultiplier * b ;
  model.w = w ;

  save(conf.modelPath, 'model') ;
else
  load(conf.modelPath) ;
end

% --------------------------------------------------------------------
%                                                Test SVM and evaluate
% --------------------------------------------------------------------

% Estimate the class of the test images  用训练集先自我检测
scores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
[drop, imageEstClass] = max(scores, [], 1) ;

% Compute the confusion matrix
idx = sub2ind([length(classes), length(classes)], ...
              imageClass(selTest), imageEstClass(selTest)) ;
confus = zeros(length(classes)) ;
confus = vl_binsum(confus, ones(size(idx)), idx) ;

% Plots（1,2,1是用训练集自己检测后的图）
figure(1) ; clf;
subplot(1,2,1) ;
imagesc(scores(:,[selTrain selTest])) ; title('Scores') ;
set(gca, 'ytick', 1:length(classes), 'yticklabel', classes) ;
subplot(1,2,2) ;
imagesc(confus) ;
title(sprintf('Confusion matrix (%.2f %% accuracy)', ...
              100 * mean(diag(confus)/conf.numTest) )) ;
print('-depsc2', [conf.resultPath '.ps']) ;
save([conf.resultPath '.mat'], 'confus', 'conf') ;
end
% -------------------------------------------------------------------------
function im = standarizeImage(im)               %图像标准化 调整大小
% -------------------------------------------------------------------------

im = im2single(im) ;
if size(im,1) > 480, im = imresize(im, [480 NaN]) ; end
end
% -------------------------------------------------------------------------
function hist = getImageDescriptor(model, im)   %获得hist描述子（就是每个K-means分类后不同的类别 到底有几个！）
% -------------------------------------------------------------------------

im = standarizeImage(im) ;
width = size(im,2) ;
height = size(im,1) ;
numWords = size(model.vocab, 2) ;

% get PHOW features
[frames, descrs] = vl_phow(im, model.phowOpts{:}) ;      %这里又是获取当前这个图像的phow特征（待分类的图片），保存了找到的每一个D-SIFT的信息

% quantize local descriptors into visual words
switch model.quantizer
  case 'vq'
    [drop, binsa] = min(vl_alldist(model.vocab, single(descrs)), [], 1) ;  %如果没有KD优化，那么就算算距离 判断在哪个类（就是SIFT分类后 一共300个）里。
  case 'kdtree'
    binsa = double(vl_kdtreequery(model.kdtree, model.vocab, ...           %如果KD树优化过了，就用KD树查找的方法 判断在哪个类里（SIFT分类后的那300个）
                                  single(descrs), ...
                                  'MaxComparisons', 50)) ;
end

for i = 1:length(model.numSpatialX)
  binsx = vl_binsearch(linspace(1,width,model.numSpatialX(i)+1), frames(1,:)) ;
  binsy = vl_binsearch(linspace(1,height,model.numSpatialY(i)+1), frames(2,:)) ;

  % combined quantization
  bins = sub2ind([model.numSpatialY(i), model.numSpatialX(i), numWords], ...
                 binsy,binsx,binsa) ;
  hist = zeros(model.numSpatialY(i) * model.numSpatialX(i) * numWords, 1) ;
  hist = vl_binsum(hist, ones(size(bins)), bins) ;
  hists{i} = single(hist / sum(hist)) ;
end
hist = cat(1,hists{:}) ;
hist = hist / sum(hist) ;                                                  %直方图归一化
end
% -------------------------------------------------------------------------
function [className, score] = classify(model, im)                          %分类函数
% -------------------------------------------------------------------------

hist = getImageDescriptor(model, im) ;
psix = vl_homkermap(hist, 1, 'kchi2', 'gamma', .5) ;
scores = model.w' * psix + model.b' ;                                      
[score, best] = max(scores) ;                                              %哪个SIFT块分最高就归为哪个
className = model.classes{best} ;
end

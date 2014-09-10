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
%   ����SIFT�ͷֲ�ֱ��ͼ + SVM������

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
%    ����CONF�е�CALDIR���ǿ���ʵ��ѵ���Լ��ļ���
%   The program can also be used to train a model on custom data by
%   pointing CONF.CALDIR to it. Just create a subdirectory for each
%   class and put the training images there. Make sure to adjust
%   CONF.NUMTRAIN accordingly.��NUMTRAINҲҪ���ű䣩
%
%   Intermediate files are stored in the directory CONF.DATADIR. All
%   such files begin with the prefix CONF.PREFIX, which can be changed
%   to test different parameter settings without overriding previous
%   results.   %�м��ļ�
%
%   The program saves the trained model in
%   <CONF.DATADIR>/<CONF.PREFIX>-model.mat. This model can be used to
%   test novel images independently of the Caltech data. %ѵ�����Ľ������λ��
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
conf.numTrain = 15 ;                                                        %ѵ��15��
conf.numTest = 15 ;                                                         %����15��
conf.numClasses = 102 ;
conf.numWords = 600 ;
conf.numSpatialX = [2 4] ;
conf.numSpatialY = [2 4] ;
conf.quantizer = 'kdtree' ;  %KD��  һ������SIFT�㷨�бر��Ķ�����������
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
classes = classes([classes.isdir]) ;                                                     %���classes�ǵõ�conf�ļ�����������
classes = {classes(3:conf.numClasses+2).name} ;                                        

% ���ǵ�demo��������ֻȡ�˼��ࣺBACKGROUND,
% FACE LEOPARDS��motorbike
images = {} ;                                                                              %���������ļ���·��+���ƣ��������                       
imageClass = {} ;                                                                          %����˵�����ļ������1��2��3��4��5
for ci = 1:length(classes)
   %IMS����ʱ����
  ims = dir(fullfile(conf.calDir, classes{ci}, '*.jpg'))' ;                                %�õ�ÿ���������������ļ��Ͷ�Ӧ��Ϣ
  ims = vl_colsubset(ims, conf.numTrain + conf.numTest) ;                                  %ѡ���ض����������ض��������ļ� ÿ��ǰ30����ǰ15��train����15��test��
  ims = cellfun(@(x)fullfile(classes{ci},x),{ims.name},'UniformOutput',false) ;            %�ļ���Ϣת�ļ�·��+����
  images = {images{:}, ims{:}} ;                                                           %images���������������������ļ�·��+���ƣ�������һ�����ӵĲ���
  imageClass{end+1} = ci * ones(1,length(ims)) ;                                           %ÿһ����Ƭ��һ���ض�����Ŷ�Ӧ��� ��һ�����1����N�����N����������
end
selTrain = find(mod(0:length(images)-1, conf.numTrain+conf.numTest) < conf.numTrain) ;     %selTrain��ÿ������������train��ͼƬ������images��ģ������� ������modȡ�����ķ��� ��
selTest = setdiff(1:length(images), selTrain) ;                                            %seldiff������ͬ�����£��Ѵ����Ե�ͼƬ����ȡ�� setdiffȡ���
imageClass = cat(2, imageClass{:}) ;                                                       %imageClassȫ��չ����һ��vector 1,1,1,1,....2,2,2,2,2....5,5,5,5,5 ÿ��30��
% 
% ��Ϣȫ������ģ�ͣ�����
model.classes = classes ;                                                   %1*5��cell �����ַ���
model.phowOpts = conf.phowOpts ;                                            %Dense-SIFT�Ĺ��в��� 
model.numSpatialX = conf.numSpatialX ;                                      
model.numSpatialY = conf.numSpatialY ;
model.quantizer = conf.quantizer ;
model.vocab = [] ;                                                         %�ʵ䣿
model.w = [] ;
model.b = [] ;
model.classify = @classify ;

% --------------------------------------------------------------------
%                                                     Train
%                                                     vocabulary��ѵ���ʵ䣩
% --------------------------------------------------------------------

if ~exist(conf.vocabPath) || conf.clobber                                   %�����⵽���ǻ�û����ѵ��(����Ϊ�˹۲������Ϊ ��conf.clobber���ó���true��

  % Get some PHOW descriptors to train the dictionary
  selTrainFeats = vl_colsubset(selTrain, 30) ;                              %�Ǿ�ѵ���ɣ������� 
  %colsubset����˼�����ѡ���������������Ǵ�ѵ�����������ѡ30�� �ղ��ܵ�ѵ��������5*15=75Ŷ
  descrs = {} ;
  %for ii = 1:length(selTrainFeats)
  for ii = 1:length(selTrainFeats)
    im = imread(fullfile(conf.calDir, images{selTrainFeats(ii)})) ;         %���ζ�ȡѵ����
    im = standarizeImage(im) ;                                              %Ԥ���� ��׼��ͼ��
    [drop, descrs{ii}] = vl_phow(im, model.phowOpts{:}) ;                   %�����úõ�phow�������õ���ǰͼ���vl_phow���
    %{
      vl_phow������ĺ��ĺ���������
      �ٷ��ĵ���http://www.vlfeat.org/matlab/vl_phow.html
      �����ĵ�˵����
      
      drop��һ��4�� M�еľ��� ����M��DSIFT�����ӵ���Ϣ
      ��һ�к͵ڶ�����ÿ�������ӵ�����
      ��������ÿ�������ӵĶԱȶȣ�����ɫǿ�Ⱦ���
      ��������ÿ�������ӵĴ�С������������λ��
      
      descrs��ÿһ�������ӵ�vector��Ϣ һ��128�� M�� ÿһ����һ��128ά�ȵ�����
      ����Ϊʲô��128ά������ǲ�ͬģ���̶��µ�SIFT Vector��ϵõ��ģ�
      
      ��֮Drop����descrs�ĸ�����Ϣ descrs����ÿ��DSIFT���ӵ���ϸ��Ϣ
    %}
  end
  
   %ȫ����ά�� ������һ����mat���� ����128�� 30*sigma(Mi)��
  descrs = vl_colsubset(cat(2, descrs{:}), 10e4) ;                         
  descrs = single(descrs) ;  %��ɵ�����
 
  
  % Quantize the descriptors to get the visual words
  %Kmeans���� �õ�vocab
  
  %{
   vl_kmeans�����������һ����Ҫ����
   �ٷ��ĵ���http://www.vlfeat.org/matlab/vl_kmeans.html
   �����������������ǰ����� DSIFT�����ӷֳ�300����ͬ�����
   �������ǵõ���һ��128�� 300�е� Mat
   ÿһ���Ǳ�ʾÿһ���---����---��λ��
  
  http://blog.csdn.net/v_july_v/article/details/8203674/
  k-means kd-tree sift��ϵ�������
  ��֮���ǰ����������͹��� ĳһ��SIFT������ vocab��λ�õ� һ�����ݽṹ
  
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
 for ii = 1:length(images)           %ע�����������е�ͼ�� 5*30=150�ţ���������������������
  % for ii = 1:length(images)
    fprintf('Processing %s (%.2f %%)\n', images{ii}, 100 * ii / length(images)) ;
    im = imread(fullfile(conf.calDir, images{ii})) ;
    hists{ii} = getImageDescriptor(model, im);                                    %�õ�HISTֱ��ͼ��������
  end

  hists = cat(2, hists{:}) ;
  save(conf.histPath, 'hists') ;                                                  %����ͼ��SIFT������Ϣ
else
  load(conf.histPath) ;
end

% --------------------------------------------------------------------
%                                                  Compute feature map
% --------------------------------------------------------------------

psix = vl_homkermap(hists, 1, 'kchi2', 'gamma', .5) ;  %��һ���ǰ�histsֱ��ͼ��һ�α任 ����chi2 SVM�˺���ʹ��

% --------------------------------------------------------------------
%                                                            Train
%                                                            SVM���ò�ͬ��ѵ������SIFTֱ��ͼ
%                                                           ����֪��ѵ������Ӧ�����ѵ��SVM��
% --------------------------------------------------------------------

if ~exist(conf.modelPath) || conf.clobber
  switch conf.svm.solver
    case {'sgd', 'sdca'}                                                     %�ж�SVM���������
      lambda = 1 / (conf.svm.C *  length(selTrain)) ;                        %ѧϰЧ�ʣ�����
      w = [] ;
      for ci = 1:length(classes)
        perm = randperm(length(selTrain)) ;                                  %�������ѵ�����С�
        fprintf('Training model for class %s\n', classes{ci}) ;
        y = 2 * (imageClass(selTrain) == ci) - 1 ;                           %y�����Ǹ� �������ĸ�class�ı�ǰ�
        [w(:,ci) b(ci) info] = vl_svmtrain(psix(:, selTrain(perm)), y(perm), lambda, ...         %��ѵ������ѵ��SVM������ ά�ȣ�SIFT��ֱ��ͼ ÿ�ֲ�ͬ��SIFT��Ӧһ��ά�ȣ�
          'Solver', conf.svm.solver, ...
          'MaxNumIterations', 50/lambda, ...
          'BiasMultiplier', conf.svm.biasMultiplier, ...
          'Epsilon', 1e-3);
      end

    case 'liblinear'                                             %��sgd��sdca���෨
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

% Estimate the class of the test images  ��ѵ���������Ҽ��
scores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
[drop, imageEstClass] = max(scores, [], 1) ;

% Compute the confusion matrix
idx = sub2ind([length(classes), length(classes)], ...
              imageClass(selTest), imageEstClass(selTest)) ;
confus = zeros(length(classes)) ;
confus = vl_binsum(confus, ones(size(idx)), idx) ;

% Plots��1,2,1����ѵ�����Լ������ͼ��
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
function im = standarizeImage(im)               %ͼ���׼�� ������С
% -------------------------------------------------------------------------

im = im2single(im) ;
if size(im,1) > 480, im = imresize(im, [480 NaN]) ; end
end
% -------------------------------------------------------------------------
function hist = getImageDescriptor(model, im)   %���hist�����ӣ�����ÿ��K-means�����ͬ����� �����м�������
% -------------------------------------------------------------------------

im = standarizeImage(im) ;
width = size(im,2) ;
height = size(im,1) ;
numWords = size(model.vocab, 2) ;

% get PHOW features
[frames, descrs] = vl_phow(im, model.phowOpts{:}) ;      %�������ǻ�ȡ��ǰ���ͼ���phow�������������ͼƬ�����������ҵ���ÿһ��D-SIFT����Ϣ

% quantize local descriptors into visual words
switch model.quantizer
  case 'vq'
    [drop, binsa] = min(vl_alldist(model.vocab, single(descrs)), [], 1) ;  %���û��KD�Ż�����ô��������� �ж����ĸ��ࣨ����SIFT����� һ��300�����
  case 'kdtree'
    binsa = double(vl_kdtreequery(model.kdtree, model.vocab, ...           %���KD���Ż����ˣ�����KD�����ҵķ��� �ж����ĸ����SIFT��������300����
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
hist = hist / sum(hist) ;                                                  %ֱ��ͼ��һ��
end
% -------------------------------------------------------------------------
function [className, score] = classify(model, im)                          %���ຯ��
% -------------------------------------------------------------------------

hist = getImageDescriptor(model, im) ;
psix = vl_homkermap(hist, 1, 'kchi2', 'gamma', .5) ;
scores = model.w' * psix + model.b' ;                                      
[score, best] = max(scores) ;                                              %�ĸ�SIFT�����߾͹�Ϊ�ĸ�
className = model.classes{best} ;
end

function [net, info] = myflower_zuo_train_fc_object()
%addpath(genpath('/data/matconvnet-1.0-beta11/'))
% vl_compilenn('enableGpu', true)
% A test for flower classification.
vl_setupnn;

opts.expDir = 'model';
opts.imdbPath ='D:/dataset/oxfordflower102/ZUO/imdb_spp_object.mat';
opts.train.batchSize = 20 ;
opts.train.numEpochs = 200 ;
opts.train.continue = true ;
opts.train.useGpu = false ;
%opts.train.learningRate = 0.005 ;
opts.train.learningRate = 0.005 ;
%expDir ÊÇ´æ·Åcnn modelµÄ
opts.train.expDir = opts.expDir ;
%opts = vl_argparse(opts, varargin) ;

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

if exist(opts.imdbPath, 'file')
  imdb = load(opts.imdbPath) ;
else
  imdb = generate_myflower_imdb() ;
  %mkdir(opts.expDir) ;
  save(opts.imdbPath,'-struct','imdb') ;
end


% Define the fully connected layer.

net.layers = {} ;

scal = 1 ;
init_bias = 0.1;

net.layers = {} ;


% Block 7
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,10752,1,256,'single'),...
                           'biases', init_bias*ones(1,256,'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'dropout', ...
                           'rate', 0.5) ;

% Block 8
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,1,256,102,'single'), ...
                           'biases', zeros(1, 102, 'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;

% Block 9
net.layers{end+1} = struct('type', 'softmaxloss') ;

% Other details
net.normalization.imageSize = [1, 10752, 1] ;
net.normalization.interpolation = 'bicubic' ;

[net,info] = cnn_train(net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2)) ;
end

% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
 db_root_path='D:/dataset/oxfordflower102/ZUO/feat_spp_object/';
% --------------------------------------------------------------------
%im = imdb.images.data(:,:,:,batch) ;
data=zeros(1,10752,1,size(batch,2));

for i=1:size(batch,2)
  im_path=[db_root_path,'image_',sprintf('%05d',batch(1,i)),'.mat'];
  load(im_path);
  im_tmp=tmp_feat-imdb.images.data_mean;
  data(:,:,:,i)=im_tmp;
end
labels = imdb.images.labels(1,batch) ;
im=single(data);
end

% --------------------------------------------------------------------
function imdb = generate_myflower_imdb()
% --------------------------------------------------------------------
   
%get image mean and image labels.
    db_root_path='D:/dataset/oxfordflower102/ZUO/feat_spp_object/';
    flower_count=8189;
     load('D:/dataset/oxfordflower102/imagelabels.mat');
    %data=zeros(im_height,im_width,3,flower_count);
    
    data_mean=zeros(1,10752);
  %  labels=zeros(1,flower_count);
   
    imdb.images.data_mean=data_mean;                                    %save mean.
    imdb.images.labels=labels;                                          %save labels.
   
%get set.(trn,val,tst)
   load('D:/dataset/oxfordflower102/setid.mat');
   set=zeros(1,flower_count);
   for i=1:flower_count
     if (ismember(i,trnid))
         set(i)=1;
     elseif (ismember(i,valid))
         set(i)=1;
     else
         set(i)=3;
     end
   end
   
   imdb.images.set=set;
end

function [net, info] = cnn_flower(varargin)

% vl_compilenn('enableGpu', true)
% A test for flower classification.
vl_setupnn;
global im_height,global im_width;
im_height=240;
im_width=320;

opts.expDir = 'model';
opts.imdbPath ='17flowers/imdb.mat';
opts.train.batchSize = 10 ;
opts.train.numEpochs = 200 ;
opts.train.continue = true ;
opts.train.useGpu = true ;
opts.train.learningRate = 0.005 ;

%expDir ÊÇ´æ·Åcnn modelµÄ
opts.train.expDir = opts.expDir ;
opts = vl_argparse(opts, varargin) ;

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

% Define a network similar to LeNet

 net.layers = {} ;

scal = 1 ;
init_bias = 0.1;

net.layers = {} ;

% Block 1
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(11, 11, 3, 96, 'single'), ...
                           'biases', zeros(1, 96, 'single'), ...
                           'stride', 4, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [3 3], ...
                           'stride', 2, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'normalize', ...
                           'param', [5 1 0.0001/5 0.75]) ;

% Block 2
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(5, 5, 48, 256, 'single'), ...
                           'biases', init_bias*ones(1, 256, 'single'), ...
                           'stride', 1, ...
                           'pad', 2, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [3 3], ...
                           'stride', 2, ...
                           'pad', 0) ;
net.layers{end+1} = struct('type', 'normalize', ...
                           'param', [5 1 0.0001/5 0.75]) ;

% Block 3
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(3,3,256,384,'single'), ...
                           'biases', init_bias*ones(1,384,'single'), ...
                           'stride', 1, ...
                           'pad', 1, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

% Block 4
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(3,3,192,384,'single'), ...
                           'biases', init_bias*ones(1,384,'single'), ...
                           'stride', 1, ...
                           'pad', 1, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;

% Block 5
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(3,3,192,256,'single'), ...
                           'biases', init_bias*ones(1,256,'single'), ...
                           'stride', 1, ...
                           'pad', 1, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'pool', ...
                           'method', 'max', ...
                           'pool', [3 3], ...
                           'stride', 2, ...
                           'pad', 0) ;

% Block 6
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(4,4,256,1024,'single'),...
                           'biases', init_bias*ones(1,1024,'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{end+1} = struct('type', 'relu') ;
net.layers{end+1} = struct('type', 'dropout', ...
                           'rate', 0.5) ;

% Block 7
net.layers{end+1} = struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,1,1024,1024,'single'),...
                           'biases', init_bias*ones(1,1024,'single'), ...
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
                           'filters', 0.01/scal * randn(1,1,1024,17,'single'), ...
                           'biases', zeros(1, 17, 'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;

% Block 9
net.layers{end+1} = struct('type', 'softmaxloss') ;

% Other details
net.normalization.imageSize = [im_height, im_width, 3] ;
net.normalization.interpolation = 'bicubic' ;
% --------------------------------------------------------------------
%                                                                Train
% --------------------------------------------------------------------

% Take the mean out and make GPU if needed
% if opts.train.useGpu
%   imdb.images.data = gpuArray(imdb.images.data) ;
% end

[net,info] = cnn_train(net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2)) ;
end


% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
 global im_width;global im_height;
 db_root_path='17flowers/';
% --------------------------------------------------------------------
%im = imdb.images.data(:,:,:,batch) ;
data=zeros(im_height,im_width,3,size(batch,2));

for i=1:size(batch,2)
  im_path=[db_root_path,'image_',sprintf('%04d',batch(1,i)),'.jpg'];
  im_tmp=imread(im_path);
  im_tmp=double(imresize(im_tmp,[im_height,im_width]));  
  im_tmp=im_tmp-imdb.images.data_mean;
  data(:,:,:,i)=im_tmp;
end
labels = imdb.images.labels(1,batch) ;
im=single(data);
end

% --------------------------------------------------------------------
function imdb = generate_myflower_imdb()
% --------------------------------------------------------------------
   
%get image mean and image labels.
    global im_width;global im_height;
    db_root_path='17flowers/';
    flower_count=1360;
    
    %data=zeros(im_height,im_width,3,flower_count);
    
    data_mean=double(zeros(im_height,im_width,3));
    labels=zeros(1,flower_count);
    
    load('truth.mat');
    
    for i=1:flower_count
      im_path=[db_root_path,'image_',sprintf('%04d',i),'.jpg'];
      im_tmp=imread(im_path);
      im_tmp=double(imresize(im_tmp,[im_height,im_width]));
      data_mean=data_mean+im_tmp;
      %data(:,:,:,i)=im_tmp;
      labels(i)=truth(i,1);
    end
    
    data_mean=data_mean./flower_count;
    imdb.images.data_mean=data_mean;                                    %save mean.
    imdb.images.labels=labels;                                          %save labels.
    %imdb.images.data=data;
    
%     for i=1:flower_count
%         imdb.images.data(:,:,:,i)=imdb.images.data(:,:,:,i)-data_mean;
%     end

   
%get set.(trn,val,tst)
   load('datasplits.mat');
   set=zeros(1,flower_count);
   for i=1:flower_count
     if (ismember(i,trn1))
         set(i)=1;
     elseif (ismember(i,val1))
         set(i)=1;
     else
         set(i)=3;
     end
   end
   
   imdb.images.set=set;



% Preapre the imdb structure, returns image data with mean image subtracted
% files = {'train-images-idx3-ubyte', ...
%          'train-labels-idx1-ubyte', ...
%          't10k-images-idx3-ubyte', ...
%          't10k-labels-idx1-ubyte'} ;
% 
% if ~exist(opts.dataDir, 'dir')
%   mkdir(opts.dataDir) ;
% end
% 
% for i=1:4
%   if ~exist(fullfile(opts.dataDir, files{i}), 'file')
%     url = sprintf('http://yann.lecun.com/exdb/mnist/%s.gz',files{i}) ;
%     fprintf('downloading %s\n', url) ;
%     gunzip(url, opts.dataDir) ;
%   end
% end
% 
% f=fopen(fullfile(opts.dataDir, 'train-images-idx3-ubyte'),'r') ;
% x1=fread(f,inf,'uint8');
% fclose(f) ;
% x1=permute(reshape(x1(17:end),28,28,60e3),[2 1 3]) ;
% 
% f=fopen(fullfile(opts.dataDir, 't10k-images-idx3-ubyte'),'r') ;
% x2=fread(f,inf,'uint8');
% fclose(f) ;
% x2=permute(reshape(x2(17:end),28,28,10e3),[2 1 3]) ;
% 
% f=fopen(fullfile(opts.dataDir, 'train-labels-idx1-ubyte'),'r') ;
% y1=fread(f,inf,'uint8');
% fclose(f) ;
% y1=double(y1(9:end)')+1 ;
% 
% f=fopen(fullfile(opts.dataDir, 't10k-labels-idx1-ubyte'),'r') ;
% y2=fread(f,inf,'uint8');
% fclose(f) ;
% y2=double(y2(9:end)')+1 ;
% 
% set = [ones(1,numel(y1)) 3*ones(1,numel(y2))];
% data = single(reshape(cat(3, x1, x2),28,28,1,[]));
% dataMean = mean(data(:,:,:,set == 1), 4);
% data = bsxfun(@minus, data, dataMean) ;
% 
% imdb.images.data = data ;
% imdb.images.data_mean = dataMean;
% imdb.images.labels = cat(2, y1, y2) ;
% imdb.images.set = set ;
% imdb.meta.sets = {'train', 'val', 'test'} ;
% imdb.meta.classes = arrayfun(@(x)sprintf('%d',x),0:9,'uniformoutput',false) ;

end

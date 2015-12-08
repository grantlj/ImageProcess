function [net, info] = cnn_bird_finetune()
%addpath(genpath('/data/matconvnet-1.0-beta11/'))
% vl_compilenn('enableGpu', true)
% A test for flower classification.
global im_height,global im_width;
im_height=224;
im_width=224;

opts.expDir = 'model';
opts.imdbPath ='D:/dataset/CUB_200_2011/imdb.mat';
opts.train.batchSize = 10 ;
opts.train.numEpochs = 200 ;
opts.train.continue = true ;
opts.train.learningRate = 0.003 ;

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
% end
load('vgg16_changed.mat');
[net,info] = cnn_train(net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2)) ;
end


% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
 global im_width;global im_height;
 db_root_path='D:/dataset/CUB_200_2011/jpg/';
% --------------------------------------------------------------------
%im = imdb.images.data(:,:,:,batch) ;
data=zeros(im_height,im_width,3,size(batch,2));

for i=1:size(batch,2)
  im_path=[db_root_path,'image_',sprintf('%05d',batch(1,i)),'.jpg'];
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
    db_root_path='D:/dataset/CUB_200_2011/jpg/';
    flower_count=8189;
    
    %data=zeros(im_height,im_width,3,flower_count);
    
    data_mean=double(zeros(im_height,im_width,3));
  %  labels=zeros(1,flower_count);
    
    load('D:/dataset/CUB_200_2011/imagelabels.mat');
    
    for i=1:flower_count
 
      im_path=[db_root_path,'image_',sprintf('%05d',i),'.jpg'];
      im_tmp=imread(im_path);
      im_tmp=double(imresize(im_tmp,[im_height,im_width]));
      data_mean=data_mean+im_tmp;
      %data(:,:,:,i)=im_tmp;
    %  labels(i)=truth(i,1);
     
    end
    
    
    data_mean=data_mean./flower_count;
    imdb.images.data_mean=data_mean;                                    %save mean.
    imdb.images.labels=labels;                                          %save labels.
    %imdb.images.data=data;
    
%     for i=1:flower_count
%         imdb.images.data(:,:,:,i)=imdb.images.data(:,:,:,i)-data_mean;
%     end

   
%get set.(trn,val,tst)
   load('D:/dataset/CUB_200_2011/setid.mat');
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

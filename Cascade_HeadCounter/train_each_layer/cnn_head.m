function [net] = cnn_head(net,en_layer)

% vl_compilenn('enableGpu', true)
% A test for flower classification.
vl_setupnn;
global im_height,global im_width;
im_height=28;
im_width=28;

opts.expDir = ['model_',num2str(en_layer)];
opts.imdbPath ='D:/dataset/Head/imdb.mat';
opts.train.batchSize = 100;
opts.train.numEpochs = 10 ;
opts.train.continue = true ;
%opts.train.useGpu = false ;
opts.train.learningRate = 0.002 ;

%expDir ÊÇ´æ·Åcnn modelµÄ
opts.train.expDir = opts.expDir ;
%opts = vl_argparse(opts, varargin) ;
opts.errorType='binary';

% --------------------------------------------------------------------
%                                                         Prepare data
% --------------------------------------------------------------------

if exist(opts.imdbPath, 'file')
  imdb = load(opts.imdbPath) ;
else
  imdb = generate_head_imdb() ;
  %mkdir(opts.expDir) ;
  save(opts.imdbPath,'-struct','imdb') ;
end

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

[net] = cnn_train(en_layer,net, imdb, @getBatch, ...
    opts.train, ...
    'val', find(imdb.images.set == 2)) ;
end


% --------------------------------------------------------------------
function [im, labels] = getBatch(imdb, batch)
im = imdb.images.data(:,:,:,batch) ;
labels = imdb.images.labels(1,batch) ;
im=single(im);
end

% --------------------------------------------------------------------
function imdb = generate_head_imdb()
% --------------------------------------------------------------------
   
%get image mean and image labels.
    global im_width;global im_height;
    pos_db_root_path='D:/dataset/Head/images/pos/';
    neg_db_root_path='D:/dataset/Head/images/neg/';
    
    %total count of heads.
    head_pos_count=5340; head_nega_count=5163;
    
    %total count of training samples.
    pos_trn_count=5340-500; nega_trn_count=5340-500;
    
    %save raw data.
    data=zeros(im_height,im_width,3,head_pos_count+head_nega_count);
    
    %save data_mean.
    data_mean=double(zeros(im_height,im_width,3));
    labels=zeros(1,head_pos_count+head_nega_count);
    
    %save trn/test label.
    set=zeros(1,head_pos_count+head_nega_count);
    
    for i=1:head_pos_count+head_nega_count
       if (i<=head_pos_count)  %is head
           im_path=[pos_db_root_path,'image_',sprintf('%04d',i),'.jpg'];
           labels(i)=1;
           if (i<=pos_trn_count); set(i)=1;else set(i)=3; end  %1 is train; 2 is test.
       else                    %is not head
           im_path=[neg_db_root_path,'image_',sprintf('%04d',i-head_pos_count),'.jpg'];
           labels(i)=-1;
           if (i-head_pos_count<=nega_trn_count); set(i)=1;else set(i)=3; end  %1 is train; 2 is test.
       end
       
       %calculate mean.
       im_tmp=imread(im_path);
       im_tmp=double(imresize(im_tmp,[im_height,im_width]));
       data_mean=data_mean+im_tmp;
       data(:,:,:,i)=im_tmp;
      
    end
    
    data_mean=data_mean/(head_pos_count+head_nega_count);
    
    for i=1:size(data,4)
      data(:,:,:,i)=data(:,:,:,i)-data_mean;
    
    end
    imdb.images.data_mean=data_mean;                                    %save mean.
    imdb.images.labels=labels;                                          %save labels.
    imdb.images.data=data;                                              %save raw data.
    imdb.images.set=set;                                                %save set id.
end

%with background ONLY!!!!! by using the segmentation info.

  level=19;                       %5,9,13,15,22
  %%
  %Segmentation result:
  %Accuarcy£º35.3553%(background only)
  
  %%
  load('net-epoch-x.mat');
  data_splits_path='D:\dataset\oxfordflower102\setid.mat';
  data_mean_path='D:\dataset\oxfordflower102\data_mean.mat';
  truth_path='D:\dataset\oxfordflower102\imagelabels.mat';
  feature_path='D:\dataset\oxfordflower102\feat_1024_BGONLY\';  %with back-ground ONLY
  image_seg_path='D:\dataset\oxfordflower102\102segmentations\segmim\';
  
  load(data_splits_path);
  load(truth_path);
  load(data_mean_path);data_mean=images.data_mean;
  
  data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  net.layers{end}.type = 'softmax';
  total=0;
  %tst1=[tst1,val1,trn1];
  
  trn1=[trnid,valid];  %use both val and test set.
  truth=labels;
 'Loading training data...'
  train_feat=zeros(size(trn1,2),1024); train_label=[];  %for feature and label, respectively.
   for i=1:size(trn1,2)
     img_count=trn1(1,i);
     %img_count=19;
     filename=['D:/dataset/oxfordflower102/jpg/','image_',sprintf('%05d',img_count),'.jpg'];
     feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
     image_seg_filename=[image_seg_path,'segmim_',sprintf('%05d',img_count),'.jpg'];  %image-segmentation file.
      label=truth(img_count);  
   %  if (~exist(feat_filename,'file'))
     im=imread(filename);   im_seg=imread(image_seg_filename);  %read segmentation file.
     im_seg=imresize(im_seg,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);

  im_seg=im_seg(:,:,1);
  im_seg(im_seg~=0)=1;
  im_seg=logical(im_seg);
  im_seg=~im_seg;
  
     im(:,:,1)=im(:,:,1).*im_seg;
     im(:,:,2)=im(:,:,2).*im_seg;
     im(:,:,3)=im(:,:,3).*im_seg;
   
   %  im=gpuArray(im);
    % label=truth(img_count);
     
     res=vl_simplenn(net,im);
     tmp_feat=gather(res(level).x(:)');
     save(feat_filename,'tmp_feat');
   %  else
          load(feat_filename);
    % end
         
   %  train_feat=[train_feat;tmp_feat];
      train_feat(i,:)=tmp_feat;
     train_label=[train_label;label];

   end
   %%
    'Loading test data...'
    tst1=tstid;
    test_feat=zeros(size(tst1,2),1024);test_label=[];
    for i=1:size(tst1,2)
     img_count=tst1(1,i);
    filename=['D:/dataset/oxfordflower102/jpg/','image_',sprintf('%05d',img_count),'.jpg'];
     feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
     image_seg_filename=[image_seg_path,'segmim_',sprintf('%05d',img_count),'.jpg'];  %image-segmentation file.
      label=truth(img_count); 
     if (~exist(feat_filename,'file'))
     im=imread(filename);   im_seg=imread(image_seg_filename);  %read segmentation file.
     im_seg=imresize(im_seg,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);
      
     im_seg=im_seg(:,:,1);
     
     im_seg(im_seg~=0)=1;
     im_seg=logical(im_seg);
     im_seg=~im_seg;
     
     im(:,:,1)=im(:,:,1).*im_seg;
     im(:,:,2)=im(:,:,2).*im_seg;
     im(:,:,3)=im(:,:,3).*im_seg;
   %  im_seg=logical(im_seg);
    % im=gpuArray(im);
   
     
     res=vl_simplenn(net,im);
     tmp_feat=gather(res(level).x(:)');
     save(feat_filename,'tmp_feat');
     
     else
         load(feat_filename);
     end
     
     
    % test_feat=[test_feat;tmp_feat];
     test_feat(i,:)=tmp_feat;
     test_label=[test_label;label];

    end
   %
   %Training SVM...
   svmmodel=svmtrain(train_label,train_feat,'-s 0 -t 0');
   clear train_label;
   clear train_feat;
   [predict_label, accuracy, prob] = svmpredict(test_label, test_feat, svmmodel);

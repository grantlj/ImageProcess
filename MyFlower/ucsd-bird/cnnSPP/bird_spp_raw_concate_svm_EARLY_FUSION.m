

%
%segmentation(SPP)+last layer 1024(original image) concate:
%Accuracy:

%segmentation(SPP)+last layer 1024(background image) concate:
%Accuarcy: 29.9374%
level=15;  %layer 19
load('net-epoch-x.mat');
data_splits_path='D:\dataset\birds\setid.mat';
data_mean_path='D:\dataset\birds\data_mean.mat';
truth_path='D:\dataset\birds\imagelabels.mat';
img_raw_path='D:\dataset\birds\jpg\';
%img_bdx_path='D:\dataset\birds\bdx_info\';
feature_path='D:\dataset\birds\feat_SPP\';
%feature_raw_path='D:\dataset\birds\feat_1024_BGONLY\';
feature_raw_path='D:\dataset\birds\feat_1024\';

load(data_splits_path);  %train, val, test split
load(truth_path);        %groundtruth.
load(data_mean_path);data_mean=images.data_mean;  %image_mean

data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
net.layers{end}.type = 'softmax';
total=0;
trn1=[trnid,valid];  %use both val and test set.
truth=labels;
  
'Loading training data...'
train_feat=zeros(size(trn1,2),11776); train_label=[];  %for feature and label, respectively.
for i=1:size(trn1,2)
 img_count=trn1(1,i);
 img_count
 filename=[img_raw_path,'image_',sprintf('%05d',img_count),'.jpg'];
 feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
 feat_raw_filename=[feature_raw_path,'image_',sprintf('%05d',img_count),'.mat'];
 
 %image_seg_filename=[img_bdx_path,'bdx_',sprintf('%05d',img_count),'.mat'];  %image-segmentation file.
 label=truth(img_count);   
 load(feat_filename);

%  train_feat=[train_feat;tmp_feat];
 tmp_feat2=tmp_feat;
 
 load(feat_raw_filename);
 tmp_feat=[tmp_feat,tmp_feat2];
 
 train_feat(i,:)=tmp_feat;
 train_label=[train_label;label];

end
%%
'Loading test data...'
tst1=tstid;
test_feat=zeros(size(tst1,2),11776);test_label=[];
for i=1:size(tst1,2)
 img_count=tst1(1,i);
 img_count
  filename=[img_raw_path,'image_',sprintf('%05d',img_count),'.jpg'];
 feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
 feat_raw_filename=[feature_raw_path,'image_',sprintf('%05d',img_count),'.mat'];
 %image_seg_filename=[img_bdx_path,'bdx_',sprintf('%05d',img_count),'.mat'];  %image-segmentation file.
 label=truth(img_count);  

 load(feat_filename);

 tmp_feat2=tmp_feat;
 
 load(feat_raw_filename);
 tmp_feat=[tmp_feat,tmp_feat2];
 
 test_feat(i,:)=tmp_feat;
 test_label=[test_label;label];

end
%
%Training SVM...
svmmodel=svmtrain(train_label,train_feat,'-s 0 -t 0');
clear train_label;
clear train_feat;
[predict_label, accuracy, prob] = svmpredict(test_label, test_feat, svmmodel);


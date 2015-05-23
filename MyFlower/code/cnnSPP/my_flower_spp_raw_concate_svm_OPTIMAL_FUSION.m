%segmentation(SPP)+last layer 1024(original image) concate LATE FUSION:
%Accuracy: 82.37%

%segmentation(SPP)+last layer 1024(background image) concate LATE FUSION:
%Accuarcy: 64.14%
level=15;  %layer 19
load('net-epoch-x.mat');
data_splits_path='D:\dataset\oxfordflower102\setid.mat';
data_mean_path='D:\dataset\oxfordflower102\data_mean.mat';
truth_path='D:\dataset\oxfordflower102\imagelabels.mat';
img_raw_path='D:\dataset\oxfordflower102\jpg\';
%img_bdx_path='D:\dataset\oxfordflower102\bdx_info\';
feature_path='D:\dataset\oxfordflower102\feat_SPP\';
%feature_raw_path='D:\dataset\oxfordflower102\feat_1024_BGONLY\';  %background only
feature_raw_path='D:\dataset\oxfordflower102\feat_1024\';        %original image

load(data_splits_path);  %train, val, test split
load(truth_path);        %groundtruth.
load(data_mean_path);data_mean=images.data_mean;  %image_mean

data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
net.layers{end}.type = 'softmax';
total=0;
trn1=[trnid,valid];  %use both val and test set.
truth=labels;
  
'Loading training data...'
train_feat_2=zeros(size(trn1,2),10752); train_label=[];  %for feature and label, respectively.
train_feat_1=zeros(size(trn1,2),1024);
for i=1:size(trn1,2)
 img_count=trn1(1,i);
 img_count
 filename=[img_raw_path,'image_',sprintf('%05d',img_count),'.jpg'];
 feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
 feat_raw_filename=[feature_raw_path,'image_',sprintf('%05d',img_count),'.mat'];
 
 %image_seg_filename=[img_bdx_path,'bdx_',sprintf('%05d',img_count),'.mat'];  %image-segmentation file.
 label=truth(img_count);   
 load(feat_filename);
 train_feat_2(i,:)=tmp_feat;

%  train_feat=[train_feat;tmp_feat];
% tmp_feat2=tmp_feat;
 
 load(feat_raw_filename);
 %tmp_feat=[tmp_feat,tmp_feat2];
 
 train_feat_1(i,:)=tmp_feat;
 train_label=[train_label;label];

end
%%
'Loading test data...'
tst1=tstid;
test_feat_2=zeros(size(tst1,2),10752);test_label=[];
test_feat_1=zeros(size(tst1,2),1024);

for i=1:size(tst1,2)
 img_count=tst1(1,i);
 img_count
  filename=[img_raw_path,'image_',sprintf('%05d',img_count),'.jpg'];
 feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
 feat_raw_filename=[feature_raw_path,'image_',sprintf('%05d',img_count),'.mat'];
 %image_seg_filename=[img_bdx_path,'bdx_',sprintf('%05d',img_count),'.mat'];  %image-segmentation file.
 label=truth(img_count);  

 load(feat_filename);

% tmp_feat2=tmp_feat;
 test_feat_2(i,:)=tmp_feat;
 
 load(feat_raw_filename);
% tmp_feat=[tmp_feat,tmp_feat2];
 
 test_feat_1(i,:)=tmp_feat;
 test_label=[test_label;label];

end
%
%Training SVM...
svmmodel_1=svmtrain(train_label,train_feat_1,'-s 0 -t 0');
svmmodel_2=svmtrain(train_label,train_feat_2,'-s 0 -t 0');


%svmmodel_2=svmmodel_1;


%%
%Using optimal fusion strategy for every individual svm.
thetaVec=get_optimal_fusion_parameter(svmmodel_1,svmmodel_2,train_label,train_feat_1,train_feat_2);

save('OPTIMAL_MODEL_SPP_ORIGIN_IM.mat','thetaVec','svmmodel_1','svmmodel_2');
%clear train_label;
%clear train_feat;
[predict_label_1, accuracy_1, prob_1] = svmpredict(test_label, test_feat_1, svmmodel_1);
[predict_label_2, accuracy_2, prob_2] = svmpredict(test_label, test_feat_2, svmmodel_2);

final_prob=prob_1+prob_2;

get_accuracy_by_prob(final_prob,test_label,102)

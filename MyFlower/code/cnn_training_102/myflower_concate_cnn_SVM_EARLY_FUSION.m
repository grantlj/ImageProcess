%myflower FOREGROUND ONLY+ALL concated SVM experiment.
%accuracy:78.9559%

%myflower BACKGROUND ONLY+ALL concated SVM experiment.
%accuracy:76.5002%
clc;
clear all;

%feature_no_bg_path='D:\dataset\oxfordflower102\feat_1024_BG\'; foreground
%feature_no_bg_path='D:\dataset\oxfordflower102\feat_1024_BGONLY\';
feature_bg_path='D:\dataset\oxfordflower102\feat_1024\';
truth_path='D:\dataset\oxfordflower102\imagelabels.mat';
data_splits_path='D:\dataset\oxfordflower102\setid.mat';

load(data_splits_path);
load(truth_path);
trn1=[trnid,valid]; truth=labels; train_label=[];
train_feat=zeros(size(trn1,2),2048); 

'Loading training data...'

for i=1:size(trn1,2)
     img_count=trn1(1,i);
     feat_no_bg_filename=[feature_no_bg_path,'image_',sprintf('%05d',img_count),'.mat'];  %load feat without bg
     load(feat_no_bg_filename);
     tmp_feat_1=tmp_feat;
     
     label=truth(img_count);
     
     feat_bg_filename=[feature_bg_path,'image_',sprintf('%05d',img_count),'.mat']; %load feat with bg
     load(feat_bg_filename);
      
     tmp_feat=[tmp_feat,tmp_feat_1];  %concate.
     train_feat(i,:)=tmp_feat;
     train_label=[train_label;label];
     
end

'Loading test data...';

 tst1=tstid;
 test_feat=zeros(size(tst1,2),2048);test_label=[];
 
 for i=1:size(tst1,2)
     img_count=tst1(1,i);
     feat_no_bg_filename=[feature_no_bg_path,'image_',sprintf('%05d',img_count),'.mat'];  %load feat without bg
     load(feat_no_bg_filename);
     tmp_feat_1=tmp_feat;
     
     label=truth(img_count);
     
     feat_bg_filename=[feature_bg_path,'image_',sprintf('%05d',img_count),'.mat']; %load feat with bg
     load(feat_bg_filename);
      
     tmp_feat=[tmp_feat,tmp_feat_1];  %concate.
     test_feat(i,:)=tmp_feat;
     test_label=[test_label;label];

 end
 
 
%Training SVM...
svmmodel=svmtrain(train_label,train_feat,'-s 0 -t 0');
clear train_label;
clear train_feat;
[predict_label, accuracy, prob] = svmpredict(test_label, test_feat, svmmodel);
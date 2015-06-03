%myflower FOREGROUND ONLY+ALL concated LATE FUSION SVM experiment.
%accuracy: 75.51%
%with optima late fusion: 74.61%

%myflower BACKGROUND ONLY+ALL concated LATE FUSION SVM experiment.
%accuracy: 67.4747%
%with optimal late fusion:63.88%
clc;
clear all;

%feature_no_bg_path='D:\dataset\oxfordflower102\feat_1024_BG\';% foreground
feature_no_bg_path='D:\dataset\oxfordflower102\feat_1024_BGONLY\';
feature_bg_path='D:\dataset\oxfordflower102\feat_1024\';
truth_path='D:\dataset\oxfordflower102\imagelabels.mat';
data_splits_path='D:\dataset\oxfordflower102\setid.mat';

load(data_splits_path);
load(truth_path);
trn1=[trnid,valid]; truth=labels; train_label=[];

train_feat_1=zeros(size(trn1,2),1024);
train_feat_2=zeros(size(trn1,2),1024);

'Loading training data...'

for i=1:size(trn1,2)
     img_count=trn1(1,i);
     feat_no_bg_filename=[feature_no_bg_path,'image_',sprintf('%05d',img_count),'.mat'];  %load feat without bg
     load(feat_no_bg_filename);
     tmp_feat_1=tmp_feat;
     
     label=truth(img_count);
     
     feat_bg_filename=[feature_bg_path,'image_',sprintf('%05d',img_count),'.mat']; %load feat with bg
     load(feat_bg_filename);
      
    % tmp_feat=[tmp_feat,tmp_feat_1];  %concate.
     train_feat_1(i,:)=tmp_feat_1;
     train_feat_2(i,:)=tmp_feat;
     train_label=[train_label;label];
     
end

'Loading test data...';

 tst1=tstid;
 %test_feat=zeros(size(tst1,2),2048);
 test_feat_1=zeros(size(tst1,2),1024);
 test_feat_2=zeros(size(tst1,2),1024);
 
 test_label=[];
 
 for i=1:size(tst1,2)
     img_count=tst1(1,i);
     feat_no_bg_filename=[feature_no_bg_path,'image_',sprintf('%05d',img_count),'.mat'];  %load feat without bg
     load(feat_no_bg_filename);
     tmp_feat_1=tmp_feat;
     
     label=truth(img_count);
     
     feat_bg_filename=[feature_bg_path,'image_',sprintf('%05d',img_count),'.mat']; %load feat with bg
     load(feat_bg_filename);
      
    % tmp_feat=[tmp_feat,tmp_feat_1];  %concate.
     test_feat_1(i,:)=tmp_feat_1;
     test_feat_2(i,:)=tmp_feat;
     test_label=[test_label;label];

 end
 
 


%%
%Using optimal fusion strategy for every individual svm.

if (~exist('OPTIMAL_MODEL_BACKGROUND_RAW.mat','file'))
  %Training SVM...
  svmmodel_1=svmtrain(train_label,train_feat_1,'-s 0 -t 0');
  svmmodel_2=svmtrain(train_label,train_feat_2,'-s 0 -t 0');
  thetaVec=get_optimal_fusion_parameter(svmmodel_1,svmmodel_2,train_label,train_feat_1,train_feat_2);
  save('OPTIMAL_MODEL_BACKGROUND_RAW.mat','thetaVec','svmmodel_1','svmmodel_2');
else
    load('OPTIMAL_MODEL_BACKGROUND_RAW.mat');
end
[predict_label_1, accuracy_1, prob_1] = svmpredict(test_label, test_feat_1, svmmodel_1);
[predict_label_2, accuracy_2, prob_2] = svmpredict(test_label, test_feat_2, svmmodel_2);

thetaMat=repmat(thetaVec',size(prob_1,1),1);

final_prob=prob_1.*thetaMat+prob_2.*(1-thetaMat);

get_accuracy_by_prob(final_prob,test_label,102)


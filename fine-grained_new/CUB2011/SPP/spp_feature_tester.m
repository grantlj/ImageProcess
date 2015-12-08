
 dataset_root_path='D:\dataset\CUB_200_2011\';
 content_feat_root_path=[dataset_root_path,'feat_content_spp_vgg_16_l31\']; mkdir(content_feat_root_path);
 context_feat_root_path=[dataset_root_path,'feat_context_spp_vgg_16_l31\']; mkdir(context_feat_root_path);
 raw_feat_root_path=[dataset_root_path,'feat_raw_image_vgg19_34\'];
 
 trn_test_split_path=[dataset_root_path,'setid.mat'];
 label_path=[dataset_root_path,'imagelabels.mat'];
 
 load(trn_test_split_path);
 load(label_path);
 
 trn_count=size(trnid,2);tst_count=size(tstid,2);
 content_trn_feat_mat=zeros(trn_count,10752); context_trn_feat_mat=zeros(trn_count,10752);
 content_tst_feat_mat=zeros(tst_count,10752); context_tst_feat_mat=zeros(tst_count,10752);
% raw_trn_feat_mat=zeros(trn_count,4096); raw_tst_feat_mat=zeros(tst_count,4096);
 trn_label=[];tst_label=[];
 
 %%
 
 
 
 %Loading training feature.
 for i=1:trn_count
    content_feat_path=[content_feat_root_path,'\image_',sprintf('%06d',trnid(i)),'.mat'];
    context_feat_path=[context_feat_root_path,'\image_',sprintf('%06d',trnid(i)),'.mat'];
    raw_feat_path=[raw_feat_root_path,'\image_',sprintf('%06d',trnid(i)),'.mat'];
    disp(['Training feature:  ',content_feat_path]);
    load(content_feat_path);load(context_feat_path);%load(raw_feat_path);
    content_trn_feat_mat(i,:)=content_feat;
    context_trn_feat_mat(i,:)=context_feat;
    %raw_trn_feat_mat(i,:)=tmp_feat;
    trn_label=[trn_label;labels(trnid(i))];
 end
 
 %%
 %Loading test feature.
  for i=1:tst_count
    content_feat_path=[content_feat_root_path,'\image_',sprintf('%06d',tstid(i)),'.mat'];
    context_feat_path=[context_feat_root_path,'\image_',sprintf('%06d',tstid(i)),'.mat'];
    raw_feat_path=[raw_feat_root_path,'\image_',sprintf('%06d',tstid(i)),'.mat'];
    disp(['Testing feature:  ',content_feat_path]);
    load(content_feat_path);load(context_feat_path);%load(raw_feat_path);
    content_tst_feat_mat(i,:)=content_feat;
    context_tst_feat_mat(i,:)=context_feat;
    %raw_tst_feat_mat(i,:)=tmp_feat;
    tst_label=[tst_label;labels(tstid(i))];
  end
 
 
  %%
  %Content only spp evaluation.
%   content_only_spp_model=svmtrain(trn_label, content_trn_feat_mat,'-s 0 -t 0');
%   save('content_only_spp_model.mat','content_only_spp_model');
load('content_only_spp_model.mat');
[predict_label, accuracy, prob_1] = svmpredict(tst_label, content_tst_feat_mat, content_only_spp_model);

%   %%
%   %Context only spp evaluation.
  context_only_spp_model=svmtrain(trn_label, context_trn_feat_mat,'-s 0 -t 0');
  save('context_only_spp_model.mat','context_only_spp_model');
  load('context_only_spp_model.mat');
  [predict_label, accuracy, prob_2] = svmpredict(tst_label, context_tst_feat_mat, context_only_spp_model);
  final_prob=prob_1+prob_2;


%raw_model=svmtrain(trn_label,raw_trn_feat_mat,'-s 0 -t 0');
%save('raw_model.mat','raw_model');
%[predict_label, accuracy, prob_2] = svmpredict(tst_label, raw_tst_feat_mat, raw_model);
%final_prob=prob_1+prob_2;
get_accuracy_by_prob(final_prob,tst_label,200)

%   [predict_label, accuracy, prob] = svmpredict(tst_label, context_tst_feat_mat, context_only_spp_model);
  
  %%
  %Content+Context late fusion evaluation.
  
  
  
  %%
  %Content+Context early fusion evaluation.
%   early_fusion_trn_feat=[content_trn_feat_mat, context_trn_feat_mat];
%   early_fusion_tst_feat=[content_tst_feat_mat, context_tst_feat_mat];
%   
%   early_fusion_spp_model=svmtrain(trn_label, early_fusion_trn_feat,'-s 0 -t 0');
%   save('early_fusion_spp_model.mat','early_fusion_spp_model');
%   [predict_label, accuracy, prob] = svmpredict(tst_label, early_fusion_tst_feat, early_fusion_spp_model);


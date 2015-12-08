function [] = proposal_feat_tester()
% 50 40, 30, 20, 10
%content:    28%   43%   53%   60%   65%
%context :   67%   66%   63%   56%   39%
%late fusion:38%   52%   65%   62%   60%
%%
  dbstop if error;
  dataset_root_path='D:\dataset\CUB_200_2011\';
  proposal_feat_root_path=[dataset_root_path,'selective_search_bbx_feat\'];
  trn_test_split_path=[dataset_root_path,'setid.mat'];
  label_path=[dataset_root_path,'imagelabels.mat'];
  
  load(trn_test_split_path);
  load(label_path);
  
  trn_count=size(trnid,2);tst_count=size(tstid,2);
  content_trn_feat_mat=zeros(trn_count,10752); context_trn_feat_mat=zeros(trn_count,10752);
  content_tst_feat_mat=zeros(tst_count,10752); context_tst_feat_mat=zeros(tst_count,10752);
  trn_label=[];tst_label=[];

  %%
  %Preparing train feat.
  [content_trn_feat_mat,context_trn_feat_mat,trn_label]=prepare_trn_tst_feat(proposal_feat_root_path,trnid,labels);
  %%
  %Preparing test feat.
  [content_tst_feat_mat,context_tst_feat_mat,tst_label]=prepare_trn_tst_feat(proposal_feat_root_path,tstid,labels);

  content_feat_model=svmtrain(trn_label, content_trn_feat_mat,'-s 0 -t 0');
  context_feat_model=svmtrain(trn_label, context_trn_feat_mat,'-s 0 -t 0');
  
  save('content_feat_model.mat','content_feat_model');
  save('context_feat_model.mat','context_feat_model');
  
  [predict_label, accuracy, prob_1] = svmpredict(tst_label, content_tst_feat_mat, content_feat_model);
  [predict_label, accuracy, prob_2] = svmpredict(tst_label, context_tst_feat_mat, context_feat_model);
  
  final_prob=prob_1+prob_2;
  get_accuracy_by_prob(final_prob,tst_label,200)
  
end

%%

%The common function used for preparing train/test dataset.
function [content_feat_mat,context_feat_mat,feat_label]=prepare_trn_tst_feat(proposal_feat_root_path,idlist,labels)
  idlist_count=size(idlist,2);
  
  content_feat_mat=zeros(idlist_count,10752);
  context_feat_mat=zeros(idlist_count,10752);
  feat_label=[];
  
  for i=1:idlist_count
    image_id=idlist(i);
    proposal_feat_path=[proposal_feat_root_path,sprintf('bbox_feat_%06d.mat',image_id)];
    disp(proposal_feat_path);
    load(proposal_feat_path);
    
    bbx_feat_count=size(bbx_feature.content_ratio,2);
    tmp_content_feat=[]; tmp_context_feat=[];
    
    for j=1:bbx_feat_count
     
      if (bbx_feature.useless{j}==1),continue,end;
     % if (bbx_feature.content_ratio{j}>=bbx_feature.content_context_th)
      if (bbx_feature.content_ratio{j}>=0.6)
          tmp_content_feat=[tmp_content_feat;bbx_feature.feat{j}];
      elseif (~isnan(bbx_feature.content_ratio{j}))
          tmp_context_feat=[tmp_context_feat;bbx_feature.feat{j}];
      end
    end
    
    now_content_feat=max(tmp_content_feat); now_context_feat=max(tmp_context_feat);
    if (~isempty(now_content_feat))
      content_feat_mat(i,:)=now_content_feat;
    end
    
    if (~isempty(now_context_feat))
      context_feat_mat(i,:)=now_context_feat;
    end
    
    feat_label=[feat_label;labels(image_id)];
  end






end


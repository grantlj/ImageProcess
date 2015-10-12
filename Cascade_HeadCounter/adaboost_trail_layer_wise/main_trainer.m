%Adaboost+logistic regression: 94.6%
%Standard SVM: 94.2% (last convolutional layer)
%The test of adaboost the response maps layerwise.

function [] = main_trainer()
addpath(genpath('liblinear-2.1/'));
pos_feat_root_path='D:/dataset/Head/feat/pos/';
neg_feat_root_path='D:/dataset/Head/feat/neg/';
pos_trn_count=5340-500; neg_trn_count=5163-500;
pos_tst_count=500;  neg_tst_count=500;
%%

%SVM on last fc layer features evaluation.
%[now_svmmodel,now_svm_test_acc]=train_simple_svm(6,pos_feat_root_path,neg_feat_root_path,pos_trn_count,neg_trn_count,pos_tst_count,neg_tst_count);  

[now_ada_model,now_ada_test_acc]=train_multilayer_adaboost(pos_feat_root_path,neg_feat_root_path,pos_trn_count,neg_trn_count,pos_tst_count,neg_tst_count); 



end

%%
function [svmmodel,test_acc]=train_simple_svm(feat_index,pos_feat_root_path,neg_feat_root_path,pos_trn_count,neg_trn_count,pos_tst_count,neg_tst_count)

 train_set=[]; train_label=[];test_set=[];test_label=[];
 'Loading traning features...'
 [pos_train_set,pos_train_label]=get_dataset(feat_index,pos_feat_root_path,1,pos_trn_count,1);
 [neg_train_set,neg_train_label]=get_dataset(feat_index,neg_feat_root_path,1,neg_trn_count,-1);
 train_set=[pos_train_set;neg_train_set]; train_label=[pos_train_label;neg_train_label];
 
 'Loading testing features...'
[pos_test_set,pos_test_label]=get_dataset(feat_index,pos_feat_root_path,pos_trn_count+1,pos_trn_count+pos_tst_count,1);
[neg_test_set,neg_test_label]=get_dataset(feat_index,neg_feat_root_path,neg_trn_count+1,neg_trn_count+neg_tst_count,-1);
test_set=[pos_test_set;neg_test_set]; test_label=[pos_test_label;neg_test_label];
 'Train SVM...'
 svmmodel=svmtrain(train_label,train_set,'-s 0 -t 0');
 'Test set evaluation...'
 [predict_label, test_acc, prob] = svmpredict(test_label, double(test_set), svmmodel);
end

%%
function [now_ada_model,now_ada_test_acc]=train_multilayer_adaboost(pos_feat_root_path,neg_feat_root_path,pos_trn_count,neg_trn_count,pos_tst_count,neg_tst_count)
%  'Loading traning features...'
%  [pos_train_set,pos_train_label]=get_dataset_for_adaboost(pos_feat_root_path,1,pos_trn_count,1);
%  [neg_train_set,neg_train_label]=get_dataset_for_adaboost(neg_feat_root_path,1,neg_trn_count,-1);
%  train_set=[pos_train_set;neg_train_set]; train_label=[pos_train_label;neg_train_label];
 
 'Loading testing features...'
[pos_test_set,pos_test_label]=get_dataset_for_adaboost(pos_feat_root_path,pos_trn_count+1,pos_trn_count+pos_tst_count,1);
[neg_test_set,neg_test_label]=get_dataset_for_adaboost(neg_feat_root_path,neg_trn_count+1,neg_trn_count+neg_tst_count,-1);
test_set=[pos_test_set;neg_test_set]; test_label=[pos_test_label;neg_test_label];

%%
%Start to train the adaboost classifier.
%  sample_count=size(train_set,1);
%  map_count=size(train_set,2);
%  %initialize the weight of each sample.
%  sample_weight=1./sample_count*ones(1,sample_count);
%  
%  %initiliaze the weight of each classifier.
%  weak_weight=1./map_count*ones(1,map_count);weak_classifier={};
%  
%  
%  for i=1:map_count
%    %A new iteration begins.
%    
%    %First, sample the training data with weights.
%    now_feat_mat=[];now_label_mat=[]; marker=zeros(1,sample_count);counter=0;
%    for j=1:sample_count
%        j
%        marker(j)=counter+1;
%        for k=1:max(1,floor(sample_count*sample_weight(1,j)))
%          counter=counter+1;
%          now_feat_mat=[now_feat_mat;train_set{j,i}];now_label_mat=[now_label_mat;train_label(j)];
%        end
%    end
%    
%    %Train a logistic regression model with libliner.
%    now_model=train(now_label_mat,sparse(double(now_feat_mat)),'-s 0');
%    weak_classifier{i}=now_model;
%    
%    %Calculate error rate on present training set.
%   [predicted_label, now_model_acc, ~]=predict(now_label_mat,sparse(double(now_feat_mat)),now_model);
%   
%    now_model_acc=now_model_acc(1,1);
%    now_model_err=(100-now_model_acc)/100;
%    now_alpha=1/2*log((1-now_model_err)/now_model_err);
%    weak_weight(1,i)=now_alpha;
%    
%    %Update weights for training samples.
%    for j=1:sample_count
%      sample_weight(1,j)=sample_weight(1,j)*exp(-now_alpha*predicted_label(marker(j))*train_label(j));
%    end
%    sample_weight=sample_weight./sum(sample_weight);
%    
%  end
% 
%  
%  now_ada_model.weak_classifier=weak_classifier;now_ada_model.weak_weight=weak_weight;
%  save('now_adaboost_model.mat','now_ada_model');
 
 %Test process.
 load('now_adaboost_model.mat');
 weak_classifier=now_ada_model.weak_classifier;weak_weight=now_ada_model.weak_weight;
 
 test_set_count=size(test_set,1);
 final_score=zeros(test_set_count,1);weak_weight=weak_weight./sum(weak_weight);
 
 
 for model_count=1:size(weak_classifier,2)
     now_model=weak_classifier{model_count};
     
     now_feat_mat=[];
     for i=1:test_set_count
       now_feat_mat=[now_feat_mat;test_set{i,model_count}];  
     end
     
     [~, ~, now_score]=predict(test_label,sparse(double(now_feat_mat)),now_model);
     final_score=final_score+now_score.*weak_weight(1,model_count);
  
 end
 
 final_score=sign(final_score);
 now_ada_test_acc=0;
 for i=1:test_set_count
   if (final_score(i)==test_label(i))  
      now_ada_test_acc=now_ada_test_acc+1;
   end
 end
 
 now_ada_test_acc=now_ada_test_acc/test_set_count;
 now_ada_test_acc
 
 
end

%%
function [dataset, label]=get_dataset_for_adaboost(feat_root_path,st,en,tag)
 label=[];
 dataset={};
  for i=st:en
    i
    feat_filename=[feat_root_path,'image_',sprintf('%04d',i),'.mat'];
    load(feat_filename);
    label=[label;tag];
    dataset=[dataset;tmp_feat];
  end

end

%%
function [organized_set]=re_organize(raw_set,row_pix,col_pix,map_count)
  organized_set={};
  for i=1:size(raw_set,1)
    now_feat=raw_set(i,:);
    shaped_feat=reshape(now_feat,[row_pix,col_pix,map_count]);
    for j=1:size(shaped_feat,3)
      organized_set{i,j}=reshape(shaped_feat(:,:,j),1,row_pix*col_pix);  
    end
      
  end

end

%%
function [dataset, label]=get_dataset(feat_index,feat_root_path,st,en,tag)
 label=[];
  for i=st:en
    i
    feat_filename=[feat_root_path,'image_',sprintf('%04d',i),'.mat'];
    load(feat_filename);
    if (i==st)
        dataset=zeros(en-st+1,size(tmp_feat{1,feat_index},2));
    end
    dataset(i-st+1,:)=tmp_feat{feat_index}; label=[label;tag];
  end

end



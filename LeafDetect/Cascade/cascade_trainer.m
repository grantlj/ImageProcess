function [] = cascade_trainer()

cascade_num=6;
recall_rate=0.9;

pos_feat_root_path='D:/dataset/HLeaf/cascade_feat/abnormal/';
neg_feat_root_path='D:/dataset/HLeaf/cascade_feat/normal/';
pos_trn_count=100; neg_trn_count=200;
pos_tst_count=70;  neg_tst_count=6228;

sub_classifier_list={};
for cascade_index=1:cascade_num
  %Train the cascade_index stage classifer.
  sub_classifier_tmp=train_cascade(recall_rate,cascade_index,pos_feat_root_path,neg_feat_root_path,pos_trn_count,neg_trn_count);
  sub_classifier_list{cascade_index}=sub_classifier_tmp;  
end


cascade_classifier.sub_classifier_list=sub_classifier_list; cascade_classifier.cascade_num=cascade_num; cascade_classifier.recall_rate=recall_rate;
save('cascade_classifier.mat','cascade_classifier');
end

%%
function [sub_classifier]=train_cascade(recall_rate,feat_index,pos_feat_root_path,neg_feat_root_path,pos_trn_count,neg_trn_count)
 validation_rate=0.95;
 train_set=[]; train_label=[];
 test_set=[]; test_label=[];
 
 
 'Loading traning features...'
 [pos_train_set,pos_train_label]=get_dataset(feat_index,pos_feat_root_path,1,pos_trn_count,1);
 [neg_train_set,neg_train_label]=get_dataset(feat_index,neg_feat_root_path,1,neg_trn_count,-1);
 train_set=[pos_train_set;neg_train_set]; train_label=[pos_train_label;neg_train_label];
 
 %Construct tiny validation set.
 total_trn=size(train_set,1); 
 randindex=randperm(total_trn);train_set=train_set(randindex,:); train_label=train_label(randindex,:);
 val_start_index=floor(total_trn*(1-validation_rate));
 val_set=train_set(val_start_index:end,:); val_label=train_label(val_start_index:end,:);
 train_set=train_set(1:val_start_index-1,:); train_label=train_label(1:val_start_index-1,:);
 
 %Train SVM.
 sub_classifier=svmtrain(train_label,train_set,'-s 0 -t 0');
 [predict_label, accuracy, prob] = svmpredict(val_label, double(val_set), sub_classifier);
 
 %Get roc curve and back-trace the best threshold.
 [recall, precision] = vl_roc(val_label, prob) ;
 
 recall_index=find(recall==recall_rate); 
 if (~isempty(recall_index))
   recall_index=recall_index(1);
   prob=sort(prob,'descend'); sub_classifier.rho=sub_classifier.rho+prob(recall_index);
 end
end

function [dataset, label]=get_dataset(feat_index,feat_root_path,st,en,tag)
 label=[];
  for i=st:en
    feat_filename=[feat_root_path,'image_',sprintf('%04d',i),'.mat'];
    load(feat_filename);
    if (i==st)
        dataset=zeros(en-st+1,size(tmp_feat{1,feat_index},2));
    end
    dataset(i-st+1,:)=tmp_feat{feat_index}; label=[label;tag];
  end

end

function [] = tester ()
 pos_feat_root_path='D:/dataset/belt_detection/feat/belted/';
 neg_feat_root_path='D:/dataset/belt_detection/feat/belt_free/';
 pos_image_root_path='D:/dataset/belt_detection/images/belted/';
 neg_image_root_path='D:/dataset/belt_detection/images/belt_free/';
%  pos_trn_count=2558; neg_trn_count=1092;
%  pos_tst_count=300;  neg_tst_count=300;
  pos_trn_count=1000; neg_trn_count=1000;
  pos_tst_count=1858;  neg_tst_count=392;
 train_set=[]; train_label=[];
 test_set=[]; test_label=[];
%  
%  'Loading traning features...'
 [pos_train_set,pos_train_label]=get_dataset(pos_feat_root_path,1,pos_trn_count,1);
 [neg_train_set,neg_train_label]=get_dataset(neg_feat_root_path,1,neg_trn_count,-1);
train_set=[pos_train_set;neg_train_set]; train_label=[pos_train_label;neg_train_label];
 
 'Loading testing features...'
 [pos_test_set,pos_test_label]=get_dataset(pos_feat_root_path,pos_trn_count+1,pos_trn_count+pos_tst_count,1);
 [neg_test_set,neg_test_label]=get_dataset(neg_feat_root_path,neg_trn_count+1,neg_trn_count+neg_tst_count,-1);
 test_set=[pos_test_set;neg_test_set]; test_label=[pos_test_label;neg_test_label];
 
 [bestCVaccuarcy,bestc,bestg,pso_option] = psoSVMcgForClass(train_label,train_set);
 
 svmmodel=svmtrain(train_label,double(train_set),'-s 0 -t 0');
 save('svmmodel.mat','svmmodel');


%%
%test 2015 dataset.
 load('svmmodel.mat');
% extra_feat_root_path='D:/dataset/HLeaf/feat/normal/';
% extra_img_root_path='D:/dataset/HLeaf/normal/';
% [extra_test_set,extra_test_label]=get_dataset(extra_feat_root_path,1,6428,-1);
[predict_label, accuracy, prob] = svmpredict(test_label, double(test_set), svmmodel);

% mkdir('hard_positive/');
% for i=1:size(predict_label,1)
%   if (predict_label(i)~=pos_test_label(i))
%     im=imread([pos_image_root_path,'image_',sprintf('%04d',pos_trn_count+i),'.jpg']);
%     imwrite(im,['hard_positive/','image_',sprintf('%04d',pos_trn_count+i),'.jpg']);
%   end
% end
end

function [dataset, label]=get_dataset(feat_root_path,st,en,tag)
  dataset=zeros(en-st+1,100); label=[];
  for i=st:en
      i
    feat_filename=[feat_root_path,'image_',sprintf('%04d',i),'.mat'];
    load(feat_filename);
    dataset(i-st+1,:)=gather(tmp_feat); label=[label;tag];
  end

end


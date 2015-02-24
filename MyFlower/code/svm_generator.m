function svm_generator()
 bow_feat_path='../dataset/bow_feat/';
 truth_path='../dataset/truth.mat';
 data_splits_path='../dataset/datasplits.mat';
 svm_model_path='../dataset/svmmodel.mat';
 %img_count=1360;
 
 load(data_splits_path);
 load(truth_path);
 
 feat_mat=zeros(size(trn1,2),1300); label_mat=zeros(size(trn1,2),1);
 
 disp(['Loading training data...']);
 for i=1:size(trn1,2)
   img_count=trn1(1,i);
   filename=[bow_feat_path,'image_',sprintf('%04d',img_count),'_bow_feat.mat'];
   load(filename);
   feat_mat(i,:)=bow_feat(1,:);
   label_mat(i,1)=truth(img_count,1);
 end
 
%  disp('Parameter searching...');
%  [bestacc,bestc,bestg] = SVMcgForClass(label_mat,feat_mat,-6,7,-6,6,3,1,1,1.5);
%  
%  bestc
%  bestg
 
 disp(['Training SVM...']);
 
 model=svmtrain(label_mat,feat_mat,'-s 0 -t 2 -c 32 -g 8 -b 1');
 save(svm_model_path,'model');
end
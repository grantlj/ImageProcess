function svm_MainTester()
 bow_feat_path='../dataset/bow_feat/';
 truth_path='../dataset/truth.mat';
 data_splits_path='../dataset/datasplits.mat';
 svm_model_path='../dataset/svmmodel.mat';
 
 
 load(data_splits_path);
 load(truth_path);
 load(svm_model_path);
 
 feat_mat=zeros(size(tst1,2),1300); label_mat=zeros(size(tst1,2),1);
 disp(['Loading testing data...']);
 for i=1:size(tst1,2)
   img_count=tst1(1,i);
   filename=[bow_feat_path,'image_',sprintf('%04d',img_count),'_bow_feat.mat'];
   load(filename);
   feat_mat(i,:)=bow_feat(1,:);
   label_mat(i,1)=truth(img_count,1);
 end
 
 disp(['Testing...']);
 
 [predict_label, accuracy, prob] = svmpredict(label_mat, feat_mat, model,'-b 1');
end
function []=main_tester()
%%
pos_image_root_path='D:/dataset/Head/images/pos/';
neg_image_root_path='D:/dataset/Head/images/neg/';
pos_trn_count=5340-500; neg_trn_count=5163-500;
pos_tst_count=500;  neg_tst_count=500;

 vl_setupnn;
 %model path:
 cnn_model_path='D:/dataset/models/head_detect_model.mat'; load(cnn_model_path);
 data_mean_path='D:/dataset/Head/data_mean.mat';load(data_mean_path);
 cascade_classifier_path='cascade_classifier.mat';load(cascade_classifier_path);
 
%%
'Generating testing file paths...'
[pos_test_set,pos_test_label]=get_dataset(pos_image_root_path,pos_trn_count+1,pos_trn_count+pos_tst_count,1);
[neg_test_set,neg_test_label]=get_dataset(neg_image_root_path,neg_trn_count+1,neg_trn_count+neg_tst_count,-1);
test_set=[neg_test_set]; test_label=[neg_test_label];
%test_set=[pos_test_set;neg_test_set]; test_label=[pos_test_label;neg_test_label];


%%
'Running baseline...'
[total_time,time_per_img,accuracy]=run_baseline(test_set,test_label,data_mean,net,cascade_classifier);
total_time               %12.0939s
time_per_img             %0.0121s
accuracy                 %0.9250

'Running cascade classifier...'
[total_time,time_per_img,accuracy]=run_cascade(test_set,test_label,data_mean,net,cascade_classifier);
total_time               % 19.0265s
time_per_img             % 0.0190s
accuracy                 % 0.8160s
end

%%
%Cascade CNN-SVM baseline.
function [total_time,time_per_img,accuracy]=run_cascade(test_set,test_label,data_mean,net,cascade_classifier)
  img_count=size(test_label,1);
  level_list=[2,3,4,5,6,7];
  accuracy=0;
  net.layers=net.layers(1:end-1);
  tic;
  
  exit_layer_hist=zeros(1,numel(net.layers));
  for i=1:img_count
     img_filename=test_set{i};
     im=imread(img_filename);
     im=imresize(im,[28,28]);
     im=double(im)-data_mean;
     im=single(im);   
     [predict_label,exit_layer]=vl_cascade_simplenn(net,im,cascade_classifier,level_list); 
     exit_layer_hist(exit_layer)=exit_layer_hist(exit_layer)+1;
     if (predict_label==test_label(i)), accuracy=accuracy+1;end;
  end
  total_time=toc;
  time_per_img=total_time/img_count;
  accuracy=accuracy/img_count;
  bar(exit_layer_hist);
end

%%
%Standard CNN-SVM baseline.
function [total_time,time_per_img,accuracy]=run_baseline(test_set,test_label,data_mean,net,cascade_classifier)
  img_count=size(test_label,1);
  svmmodel=cascade_classifier.sub_classifier_list{6};
  level=7;
  accuracy=0;
  net.layers=net.layers(1:end-1);
  tic;
  for i=1:img_count
     img_filename=test_set{i};
      im=imread(img_filename);
      im=imresize(im,[28,28]);
      im=double(im)-data_mean;
      im=single(im); 
      %tic;
      res=vl_simplenn_here(net,im);
      
      %toc;
      
      %tic;
      tmp_feat=gather(res(level).x(:)');
      [predict_label, ~,~] = svmpredict(test_label(i), double(tmp_feat), svmmodel);
     % toc;
      
      if (predict_label==test_label(i)), accuracy=accuracy+1;end;
  end
  total_time=toc;
  time_per_img=total_time/img_count;
  accuracy=accuracy/img_count;



end

%%
%Generate dataset.
function [dataset, label]=get_dataset(feat_root_path,st,en,tag)
  dataset={}; label=[];
  for i=st:en
      %i
    feat_filename=[feat_root_path,'image_',sprintf('%04d',i),'.jpg'];
    dataset{i-st+1,1}=feat_filename;
    label=[label;tag];
  end

end

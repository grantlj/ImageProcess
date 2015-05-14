function []=cnn_mnist_naive_SVM()
%New version, with more samples.
% optimization finished, #iter = 12198
% nu = 0.000010
% obj = -0.706081, rho = -0.536070
% nSV = 250, nBSV = 0
% Total nSV = 250
% Accuracy = 88.7143% (1242/1400) (classification)

%==========================================
%The old version, with fewer samples.
% optimization finished, #iter = 286
% nu = 0.000002
% obj = -0.074090, rho = -1.631911
% nSV = 37, nBSV = 0
% Total nSV = 37
% Accuracy = 76.681% (536/699) (classification)
  
load('net-epoch-100.mat');
  
  data_mean_path='dataset/data_mean.mat';
  global feature_path;
  feature_path='dataset/feat_cnn_mnist/';
  neg_path='cropped/neg/';
  pos_path='cropped/pos/';
  load(data_mean_path);
  global data_mean;
  data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  net.layers{end}.type = 'softmax';
 
  global net;
  %tst1=[tst1,val1,trn1];
  
 'Loading training and testing data...'
 
 [pos_trn_data,pos_trn_label,pos_tst_data,pos_tst_label]=get_trn_tst_data(pos_path,676,1076,[feature_path,'pos/'],1);
 [neg_trn_data,neg_trn_label,neg_tst_data,neg_tst_label]=get_trn_tst_data(neg_path,676,1676,[feature_path,'neg/'],-1);

   %%
   %Training SVM...
  % [bestCVaccuarcy,bestc,bestg,pso_option] = psoSVMcgForClass([pos_trn_label;neg_trn_label],[pos_trn_data;neg_trn_data]);
   svmmodel=svmtrain([pos_trn_label;neg_trn_label],[pos_trn_data;neg_trn_data],'-s 0 -t 0 -c 100 -g 0.01');
   %clear train_label;
  % clear train_feat;
   [predict_label, accuracy, prob] = svmpredict([pos_tst_label;neg_tst_label], [pos_tst_data;neg_tst_data], svmmodel);
   
end

function [trn_data,trn_label,tst_data,tst_label]=get_trn_tst_data(path,trn_absolute_value,all_count,feature_root_path,present_label)

global data_mean;
global net;
trn_data=[];
trn_label=[];
tst_data=[];
tst_label=[];

for i=1:all_count
  im_filename=[path,'image_',sprintf('%04d',i),'.jpg'];
  feat_filename=[feature_root_path,'image_',sprintf('%04d',i),'.mat']
  if (~exist(feat_filename,'file'))
      im=imread(im_filename);
      im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
      im=double(im)-data_mean;
      im=single(im);
      res=vl_simplenn(net,im);
      tmp_feat=gather(res(7).x(:)');
      save(feat_filename,'tmp_feat');
  else
      load(feat_filename);
  end
  
  if (i<=trn_absolute_value)
      trn_data=[trn_data;tmp_feat];
      trn_label=[trn_label;present_label];
  else
      tst_data=[tst_data;tmp_feat];
      tst_label=[tst_label;present_label];
  end
end

trn_data=double(trn_data);
tst_data=double(tst_data);
end
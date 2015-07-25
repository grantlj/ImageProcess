function [bdx_label_mat]=head_counter_release(img_path,bdx_label_mat)
vl_setupnn;

load('cnn_mnist_naive_SVM_model.mat');

%load net info(optional)
load('net-epoch-150.mat');
%load('cropped/imdb.mat');
load('data_mean.mat');
data_mean=images.data_mean;
net.layers{end}.type = 'softmax';

level=7;

im_raw=imread(img_path);

bdx_label_mat=floor(bdx_label_mat);

cnn_bdx_index=[];
bdx_label_mat

for i=1:size(bdx_label_mat,1)

  now_vec=floor(bdx_label_mat(i,:));
  im_patch=im_raw(max(1,now_vec(2)):now_vec(2)+now_vec(4),max(1,now_vec(1)):now_vec(1)+now_vec(3),:);
  size(im_patch)
  im_patch=imresize(im_patch,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  im_patch=double(im_patch)-data_mean;
  im_patch=single(im_patch);
  res=vl_simplenn(net,im_patch);
  tmp_feat=double(gather(res(level).x(:)'));

  [predict_label, accuracy, prob] = svmpredict(1, tmp_feat, svmmodel);   

  if (prob>0)
      im_raw = insertObjectAnnotation(im_raw,'rectangle',now_vec,' ');
      cnn_bdx_index=[cnn_bdx_index;i];
  end
end

bdx_label_mat=uint16(bdx_label_mat(cnn_bdx_index,:));
bdx_label_mat
end
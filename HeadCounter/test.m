clear all;
clc;

%im1=imread('figure_raw/1.jpg');

%path of bounding box ground truth.

%path of raw figure;
figure_raw_root_path='dataset/figure_raw/';

%path of bounding box detected.
bdx_labeled_root_path='dataset/boundingbox_deteced/';


%paths for CNN output
bdx_cnn_root_path='dataset/boundingbox_cnn_mnist_plus/';
mkdir(bdx_cnn_root_path);
figure_cnn_root_path='dataset/figure_cnn_mnist_plus/';
mkdir(figure_cnn_root_path);
load('cnn_mnist_naive_SVM_model.mat');


%load net info(optional)
load('net-epoch-100.mat');
load('cropped/imdb.mat');
data_mean=images.data_mean;
net.layers{end}.type = 'softmax';

level=7;

%read ground truth file, raw image file and labeled bounding box file,
%respectively.

for img_count=1:100
   % bdx_gt_file=[bdx_gt_root_path,num2str(img_count),'.txt'];
    figure_raw_file=[figure_raw_root_path,num2str(img_count),'.jpg'];
    bdx_label_file=[bdx_labeled_root_path,num2str(img_count),'.txt'];

    im_raw=imread(figure_raw_file);
    im_raw_2=im_raw;

    bdx_label_mat=importdata(bdx_label_file);

    bdx_label_mat=floor(bdx_label_mat);

%     %label detected heads.
%     for i=1:size(bdx_label_mat,1)
%       now_vec=bdx_label_mat(i,:);
%       im_raw_2 = insertObjectAnnotation(im_raw_2,'rectangle',now_vec,['head-',num2str(i)]);
%     end
% 
% 
%     %subplot(1,2,2);
%     figure;
%     imshow(im_raw_2);

    %using CNN feature.
    
    cnn_bdx_index=[];

    for i=1:size(bdx_label_mat,1)
     
     out_bdx_file_name=[bdx_cnn_root_path,num2str(img_count),'.mat'];
     out_im_file_name=[figure_cnn_root_path,num2str(img_count),'.jpg'];
     
     if (exist(out_bdx_file_name,'file'))
         continue;
     end
        
      now_vec=floor(bdx_label_mat(i,:));
      im_patch=im_raw(max(1,now_vec(2)):now_vec(2)+now_vec(4),max(1,now_vec(1)):now_vec(1)+now_vec(3),:);

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
    imwrite(im_raw,out_im_file_name);
    save(out_bdx_file_name,'bdx_label_mat');
  %  save(out_bdx_file_name,'bdx_label_mat','-ascii');
   % figure;
   % imshow(im_raw);
    %overlapRatio = bboxOverlapRatio(bdx_label_mat,bdx_gt_mat)
end
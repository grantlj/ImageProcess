function []=feat_extractor()
 %model path:
 model_path='D:/dataset/belt_detection/80permodels/net-epoch-18.mat';
 data_mean_path='D:/dataset/belt_detection/data_mean.mat';
%normal:
% image_root_path='D:/dataset/belt_detection/images/belted/';
% feat_root_path='D:/dataset/belt_detection/feat/belted/';
% image_count=10166;

%image_root_path='D:/dataset/belt_detection/images/belt_free/';
%feat_root_path='D:/dataset/belt_detection/feat/belt_free/';
%image_count=2010;

image_root_path='D:/dataset/belt_detection/images/belt_testset_1119/';
feat_root_path='D:/dataset/belt_detection/feat/belt_testset_1119/';
image_count=518;

mkdir(feat_root_path);
 

 load(model_path);
 load(data_mean_path);
 net.layers=net.layers(1:end-1);
 for i=1:image_count
   i
   img_filename=[image_root_path,'image_',sprintf('%05d',i),'.jpg'];
   feat_filename=[feat_root_path,'image_',sprintf('%05d',i),'.mat'];
  %if (~exist(feat_filename,'file'))
       im=double(imread(img_filename));
       %im=im./(max(max(im))-min(min(im)))*255;
       %im=imadjust(im);
       im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
       
       im=double(im)-data_mean;
       im=single(im); 
       res=vl_simplenn(net,im);
       tmp_feat=gather(res(12).x(:)');
       save(feat_filename,'tmp_feat');
  % end
 end
 

end
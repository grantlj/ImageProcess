function []=feat_extractor()
 vl_setupnn;
 %model path:
 model_path='D:/dataset/models/imagenet-vgg-verydeep-19.mat';
 data_mean_path='D:/dataset/belt_detection/data_mean.mat';
%normal:
image_root_path='D:/dataset/belt_detection/images/belted/';
feat_root_path='D:/dataset/belt_detection/feat/belted/';
image_count=10166;

%image_root_path='D:/dataset/belt_detection/images/belt_free/';
%feat_root_path='D:/dataset/belt_detection/feat/belt_free/';
%image_count=2010;

%image_root_path='D:/dataset/belt_detection/images/vague/';
%feat_root_path='D:/dataset/belt_detection/feat/vague/';
%image_count=5747;

mkdir(feat_root_path);
 

 net=load(model_path);
 %net.layers=net.layers(1:end-1);
 %load(data_mean_path);

 level_list=[6,11,20,29,38,42];
 for i=1:image_count
   i
   img_filename=[image_root_path,'image_',sprintf('%05d',i),'.jpg'];
   feat_filename=[feat_root_path,'image_',sprintf('%05d',i),'.mat'];
  %if (~exist(feat_filename,'file'))
       im=double(imread(img_filename));
       %im=im./(max(max(im))-min(min(im)))*255;
       %im=imadjust(im);
       im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
       
       im=double(im)-net.normalization.averageImage;
       im=single(im); 
       res=vl_simplenn(net,im);
       tmp_feat={};
       for p=1:size(level_list,2)
         tmp_feat{p}=gather(res(level_list(1,p)).x(:)');
       end
       save(feat_filename,'tmp_feat');
  % end
 end
 

end
function []=feat_extractor()
 vl_setupnn;
 %model path:
 model_path='D:/dataset/models/imagenet-vgg-verydeep-19.mat';
 data_mean_path='D:/dataset/HLeaf/data_mean.mat';
 %abnormal:
%  image_root_path='D:/dataset/HLeaf/abnormal/';
%  feat_root_path='D:/dataset/HLeaf/feat/abnormal/';
%  image_count=170;
 
 %normal:
 image_root_path='D:/dataset/HLeaf/other/20150926/';
 feat_root_path='D:/dataset/HLeaf/feat/20150926/';
 image_count=117;
 
 level=42;
 net=load(model_path);
 load(data_mean_path);
 for i=1:image_count
   i
   img_filename=[image_root_path,'image_',sprintf('%04d',i+170),'.jpg'];
   feat_filename=[feat_root_path,'image_',sprintf('%04d',i+170),'.mat'];
   if (~exist(feat_filename,'file'))
       im=imread(img_filename);
       im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
       im=double(im)-data_mean;
       im=single(im); 
       res=vl_simplenn(net,im);
       tmp_feat=gather(res(level).x(:)');
       save(feat_filename,'tmp_feat');
   end
 end
 

end
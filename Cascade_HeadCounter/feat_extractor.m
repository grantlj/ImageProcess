function []=feat_extractor()
 vl_setupnn;
 %model path:
 model_path='D:/dataset/models/head_detect_model.mat';
 data_mean_path='D:/dataset/Head/data_mean.mat';
 %neg:
%  image_root_path='D:/dataset/Head/images/neg/';
%  feat_root_path='D:/dataset/Head/feat/neg/';
%  image_count=5163;
 
 %pos:
 image_root_path='D:/dataset/Head/images/pos/';
 feat_root_path='D:/dataset/Head/feat/pos/';
 image_count=5340;
 
 mkdir(feat_root_path);
 %level=42;
 level_list=[2,3,4,5,6,7];
 load(model_path);
 load(data_mean_path);
 net.layers=net.layers(1:end-1);
 for i=1:image_count
   i
   img_filename=[image_root_path,'image_',sprintf('%04d',i),'.jpg'];
   feat_filename=[feat_root_path,'image_',sprintf('%04d',i),'.mat'];
   if (~exist(feat_filename,'file'))
       im=imread(img_filename);
       im=imresize(im,[28,28]);
       im=double(im)-data_mean;
       im=single(im); 
       res=vl_simplenn(net,im);
       tmp_feat={};
       for p=1:size(level_list,2)
         tmp_feat{p}=gather(res(level_list(1,p)).x(:)');
       end
       save(feat_filename,'tmp_feat');
   end
 end
 

end
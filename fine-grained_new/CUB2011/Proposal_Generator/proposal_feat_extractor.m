function [] = proposal_feat_extractor()
%%
% dbstop if error;
 model_path='D:/dataset/models/CUB200-vgg16-finetuned.mat';
 load(model_path);target_layer=31;
 net.layers=net.layers(1:31);
 
 data_mean_path='D:\dataset\CUB_200_2011\data_mean.mat';
 load(data_mean_path);
 data_mean=images.data_mean;
 clear images;
 
 image_count=11788;
 image_root_path='D:/dataset/CUB_200_2011/images/images/';
 selective_search_bbx_path='D:/dataset/CUB_200_2011/selective_search_bbx_list/';
 selective_search_bbx_feat='D:/dataset/CUB_200_2011/selective_search_bbx_feat/';
 mkdir(selective_search_bbx_feat);
 segmentation_root_path='D:/dataset/CUB_200_2011/segmentations/fcn8s-cub_200_2011/';
 
 %content/context threshold. >0.4:content;<0.4:context.
 content_context_th=0.4;
%%
for i=1:image_count
   
   bbx_feature.content_context_th=0.4;
  

 % figure(i);
  image_path=[image_root_path,sprintf('image_%06d.jpg',i)]; 
  disp(image_path);
  im_seg_path=[segmentation_root_path,sprintf('image_%06d.jpg',i)];
  
  %transfer segmentataion result to binary value.
  im_seg_result=do_seg_initialization(im_seg_path);
  
  image_bbx_list_path=[selective_search_bbx_path,sprintf('bbox_%06d.mat',i)];
  image_bbx_feat_path=[selective_search_bbx_feat,sprintf('bbox_feat_%06d.mat',i)];
  if (exist(image_bbx_feat_path,'file'))
       continue;
  end
  im=imread(image_path);im_height=size(im,1);im_width=size(im,2);
  if (size(im,3)==1)
      im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,2);
  end
  
  load(image_bbx_list_path);
  now_data_mean=imresize(data_mean,[size(im,1),size(im,2)]);
  im=single(im)-single(now_data_mean);
  
  im_res=vl_simplenn(net,im);
  
  %target feature map size.
  fm_h=size(im_res(target_layer).x,1);fm_w=size(im_res(target_layer).x,2);
  
  
  %%
  %Handling each bounding box.
  for boxes_count=1:size(boxes,1)
    
     coord=boxes(boxes_count,:);  
     
     %calculate content ratio.
     content_ratio=im_seg_result(coord(3),coord(4))+im_seg_result(coord(1),coord(2))-im_seg_result(coord(3),coord(2))-im_seg_result(coord(1),coord(4));
    
     x=coord(2);y=coord(1);w=coord(4)-coord(2);h=coord(3)-coord(1);
     content_ratio=content_ratio./(w*h);
     
     bbx_feature.content_ratio{boxes_count}=content_ratio;
     
     %in up-left and down-right format.
     %images{idx} = image(bbox(1):bbox(3),bbox(2):bbox(4),:);
     if (w*h<=1/24*(im_width*im_height))
         
         bbx_feature.useless{boxes_count}=1;
         bbx_feature.feat{boxes_count}=[];
         continue;
         
     end
     
     bbx_feature.useless{boxes_count}=0;
     
      %feature map bounding box coordinate.
      coordp(1)=max(1,floor(coord(1)*fm_h/im_height));  coordp(3)=min(floor(coord(3)*fm_h/im_height),fm_h); 
      coordp(2)=max(1,floor(coord(2)*fm_w/im_width));   coordp(4)=min(floor(coord(4)*fm_w/im_width),fm_w); 
      
      try
        vec=get_spp_feat(im_res(target_layer).x(coordp(1):coordp(3),coordp(2):coordp(4),:));
      catch
        bbx_feature.useless{boxes_count}=1;
        vec=[];
        disp('An internal error occurs...');
      end
      bbx_feature.feat{boxes_count}=vec;
      
%%%%%%% Debug use %%%%%%%%%     
%      imshow(im);
%      rectangle('Position',[x,y,w,h],'EdgeColor','g');
%      hold on; 
%      pause;
  end
  
 % close(figure(i));
 save(image_bbx_feat_path,'bbx_feature');
 clear bbx_feature;
end
end

%%
function [im_seg_result]=do_seg_initialization(im_seg_path)
  im_seg=imread(im_seg_path);
  im_seg_result=ones(size(im_seg,1),size(im_seg,2));
  
  for i=1:size(im_seg,1)
     for j=1:size(im_seg,2)
        if (im_seg(i,j,1)==0 && im_seg(i,j,2)==0 && im_seg(i,j,3)==0)  
          im_seg_result(i,j)=0;
        end
         
     end
  end
 im_seg_result_raw=double(im_seg_result);
 %Calculate integral image.
 im_seg_result=double(zeros(size(im_seg,1),size(im_seg,2)));
 
  for i=1:size(im_seg,1)
     for j=1:size(im_seg,2)
         if i==1 && j==1           
            im_seg_result(i,j)=im_seg_result_raw(i,j);
        elseif i==1 && j~=1        
            im_seg_result(i,j)=im_seg_result(i,j-1)+im_seg_result_raw(i,j);
        elseif i~=1 && j==1        
            im_seg_result(i,j)=im_seg_result(i-1,j)+im_seg_result_raw(i,j);
         else                        
            im_seg_result(i,j)= im_seg_result_raw(i,j)+ im_seg_result(i-1,j)+ im_seg_result(i,j-1)- im_seg_result(i-1,j-1);  
        end 
         
     end
  end
 
 
end

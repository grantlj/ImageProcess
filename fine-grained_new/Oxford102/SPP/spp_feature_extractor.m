function spp_feature_extractor()
  dataset_root_path='D:\dataset\oxfordflower102\';
  image_root_path=[dataset_root_path,'jpg\'];
  bdx_root_path=[dataset_root_path,'bdx_info\'];
  image_seg_root_path='D:\dataset\oxfordflower102\102segmentations\segmim\';
  
  data_mean_path=[dataset_root_path,'data_mean.mat'];
  load(data_mean_path);
  data_mean=images.data_mean;
  clear images;
   
  image_count=8189;
  
  load('D:\dataset\models\Oxford102-vgg16-finetuned.mat');
  net.layers=net.layers(1:end-1);
  
  content_feat_root_path=[dataset_root_path,'feat_content_spp_vgg_16_l31\']; mkdir(content_feat_root_path);
  context_feat_root_path=[dataset_root_path,'feat_context_spp_vgg_16_l31\']; mkdir(context_feat_root_path);

err_count=[];
%%
  for i=1:image_count  
     now_img_path=[image_root_path,sprintf('image_%05d.jpg',i)];
     disp(now_img_path);
     im=imread(now_img_path);
     
     now_data_mean=imresize(data_mean,[size(im,1),size(im,2)]);
     
     if (size(im,3)==1)
       im(:,:,2)=im(:,:,1);
       im(:,:,3)=im(:,:,1);
     end
     
    bdx_file_name=[bdx_root_path,'bdx_',sprintf('%05d',i),'.mat'];
    load(bdx_file_name);
    
    now_x=x_min;now_y=y_min;now_w=x_max-x_min;now_h=y_max-y_min; 
    
    %extract content spp.
    content_feat_path=[content_feat_root_path,'\image_',sprintf('%05d',i),'.mat'];
    context_feat_path=[context_feat_root_path,'\image_',sprintf('%05d',i),'.mat'];
    
    if (now_x==0), now_x=now_x+1;end
    if (now_y==0), now_y=now_y+1;end
    
    if (~exist(content_feat_path,'file'))
       
            content_im=single(im)-single(now_data_mean); 
            content_feat_res=vl_simplenn(net,single(content_im));
            content_feat=get_spp_feat(content_feat_res(31).x);
            save(content_feat_path,'content_feat');
            
    end
    
     if (~exist(context_feat_path,'file'))
            %Extract segmentation info.
            im_shadow_path=[image_seg_root_path,'segmim_',sprintf('%05d',i),'.jpg'];  
            im_seg=imread(im_shadow_path);
            
             res=xor(im,im_seg);
             %res=res(:,:,1).*res(:,:,2).*res(:,:,3);
             res=~uint8(res)*255;
             res=res(:,:,1);

             BW2 = bwareaopen(res,100);
             BW2 = imclearborder(BW2);
             [tmp_x,tmp_y]=find(BW2==0);

            context_im=single(im)-single(now_data_mean);
            for tmp_ite=1:size(tmp_x,1)
               context_im(tmp_x(tmp_ite),tmp_y(tmp_ite))=single(now_data_mean(tmp_x(tmp_ite),tmp_y(tmp_ite))); 
            end
            %context_im(max(1,now_y):min(size(im,1),max(1,now_y)+now_h-1),max(1,now_x):min(size(im,2),now_x+now_w-1),:)=now_data_mean(max(1,now_y):min(size(im,1),now_y+now_h-1),max(1,now_x):min(size(im,2),now_x+now_w-1),:);
            context_feat_res=vl_simplenn(net,single(context_im));
            context_feat=get_spp_feat(context_feat_res(31).x);

            save(context_feat_path,'context_feat');
            
    end
    
    
  end
  system('shutdown -s');
save('err_count.mat','err_count');
end
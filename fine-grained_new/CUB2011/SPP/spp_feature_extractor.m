function spp_feature_extractor()
  dataset_root_path='D:\dataset\CUB_200_2011\';
  image_root_path=[dataset_root_path,'images\images\'];
  bdx=load('bounding_box_info.mat');
  
  data_mean_path=[dataset_root_path,'data_mean.mat'];
  load(data_mean_path);
  data_mean=images.data_mean;
  clear images;
  
  image_count=11788;
  
  net=load('imagenet-vgg-verydeep-16_for_spp.mat');
  
  content_feat_root_path=[dataset_root_path,'feat_content_spp_vgg_16_l31\']; mkdir(content_feat_root_path);
  context_feat_root_path=[dataset_root_path,'feat_context_spp_vgg_16_l31\']; mkdir(context_feat_root_path);

%%
  for i=1:image_count  
     now_img_path=[image_root_path,sprintf('image_%06d.jpg',i)];
     disp(now_img_path);
     im=imread(now_img_path);
     
     now_data_mean=imresize(data_mean,[size(im,1),size(im,2)]);
     
     if (size(im,3)==1)
       im(:,:,2)=im(:,:,1);
       im(:,:,3)=im(:,:,1);
     end
    now_x=bdx.x(i);now_y=bdx.y(i);now_w=bdx.w(i);now_h=bdx.h(i); 
    
    %extract content spp.
    content_feat_path=[content_feat_root_path,'\image_',sprintf('%06d',i),'.mat'];
    context_feat_path=[context_feat_root_path,'\image_',sprintf('%06d',i),'.mat'];
    
    if (now_x==0), now_x=now_x+1;end
    if (now_y==0), now_y=now_y+1;end
    
    if (~exist(content_feat_path,'file'))
            content_im=im(max(1,now_y):min(size(im,1),now_y+now_h-1),max(1,now_x):min(size(im,2),now_x+now_w-1),:);
            content_im=single(content_im)-single(now_data_mean(max(1,now_y):min(size(im,1),now_y+now_h-1),max(1,now_x):min(size(im,2),now_x+now_w-1),:));
            content_feat_res=vl_simplenn(net,single(content_im));
            content_feat=get_spp_feat(content_feat_res(31).x);

            save(content_feat_path,'content_feat');
            
    end
    
     if (~exist(context_feat_path,'file'))
           
            context_im=single(im)-single(now_data_mean);
            %context_im(max(1,now_y):min(size(im,1),max(1,now_y)+now_h-1),max(1,now_x):min(size(im,2),now_x+now_w-1),:)=now_data_mean(max(1,now_y):min(size(im,1),now_y+now_h-1),max(1,now_x):min(size(im,2),now_x+now_w-1),:);
            context_feat_res=vl_simplenn(net,single(context_im));
            context_feat=get_spp_feat(context_feat_res(31).x);

            save(context_feat_path,'context_feat');
            
    end
    
    
  end

end
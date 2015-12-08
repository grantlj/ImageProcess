function gao_fusion_test()

%UCSD-BIRD 200:
vl_setupnn;

flower_count=11788;

content_db_root_path='D:\dataset\CUB_200_2011\feat_content_spp_vgg_16_l31/';
context_db_root_path='D:\dataset\CUB_200_2011\feat_context_spp_vgg_16_l31/';

set_split_path='D:\dataset\CUB_200_2011\setid.mat';
label_path='D:\dataset\CUB_200_2011\imagelabels.mat';
[set labels]=get_set_split_info(flower_count,set_split_path,label_path);
img_id=get_now_batch_id(set);
sel_imgs=img_id;
lr=0.005;
[content_feat, context_feat, img_labels]=load_features(sel_imgs,content_db_root_path,context_db_root_path,labels);

errlist=[];
for i=1:150
    model_filename=['model/net-epoch-',num2str(i),'.mat'];
    load(model_filename);
    init_state=0;
    [net,res,dldu,err]=gao_nn_update(content_feat,context_feat,img_labels,net,0,lr,init_state);  %test mode.
    errlist=[errlist,err];
    1-err
end

 figure(1) ; clf ;
 semilogy(1:size(errlist,2), errlist, 'k') ; hold on ;
 xlabel('training epoch') ; ylabel('test err') ;
 grid on ;
  title('Test Err') ;
end



function [img_id]=get_now_batch_id(set, batchSize)
  img_id=find(set==3);
  rand_indice=randperm(size(img_id,2));
  img_id=img_id(rand_indice);
end


function [contents_feat, contexts_feat, img_labels]=load_features(sel_imgs,content_db_root_path,context_db_root_path,labels)
  img_labels=labels(sel_imgs);
  contents_feat=[];contexts_feat=[];
  for i=1:size(sel_imgs,2)
    now_img_content_path=[content_db_root_path,'image_',sprintf('%06d',sel_imgs(1,i)),'.mat'];  
    now_img_context_path=[context_db_root_path,'image_',sprintf('%06d',sel_imgs(1,i)),'.mat'];  
    
    %load content feat.
    load(now_img_content_path);
    contents_feat=[contents_feat;content_feat];
    
    %load context feat.
    load(now_img_context_path);
    contexts_feat=[contexts_feat;context_feat];
  end
  'Finish loading...'
end


%return the set split info.
function [set,labels]=get_set_split_info(flower_count,set_split_path,label_path)
   load(set_split_path);
   set=zeros(1,flower_count);
   for i=1:flower_count
       if (ismember(i,trnid))
         set(i)=1;
     else
         set(i)=3;
     end
   end
   
   load(label_path);
end


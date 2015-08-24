function gao_fusion_test()

%UCSD-BIRD 200:
vl_setupnn;

flower_count=6033;
%content_db_root_path='D:/dataset/birds/ZUO/feat_spp_object/';
%context_db_root_path='D:/dataset/birds/ZUO/feat_spp_context/';

%distortion d1: 41.59%
%distortion d2: 41.49%
%distortion d3: 40.96%
%distortion d4: 40.70%
%distortion d5: 40.17%
content_db_root_path='D:/dataset/birds/ZUO/feat_spp_content_d1/';
context_db_root_path='D:/dataset/birds/ZUO/feat_spp_context_d1/';

set_split_path='D:/dataset/birds/setid.mat';
label_path='D:/dataset/birds/imagelabels.mat';
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


function [content_feat, context_feat, img_labels]=load_features(sel_imgs,content_db_root_path,context_db_root_path,labels)
  img_labels=labels(sel_imgs);
  content_feat=[];context_feat=[];
  for i=1:size(sel_imgs,2)
    now_img_content_path=[content_db_root_path,'image_',sprintf('%05d',sel_imgs(1,i)),'.mat'];  
    now_img_context_path=[context_db_root_path,'image_',sprintf('%05d',sel_imgs(1,i)),'.mat'];  
    
    %load content feat.
    load(now_img_content_path);
    content_feat=[content_feat;tmp_feat];
    
    %load context feat.
    load(now_img_context_path);
    context_feat=[context_feat;tmp_feat];
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
     elseif (ismember(i,valid))
         set(i)=3;
     else
         set(i)=3;
     end
   end
   
   load(label_path);
end


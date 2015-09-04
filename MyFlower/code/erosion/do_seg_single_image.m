function do_seg_single_image(im_org_path,im_shadow_path,feat_path,dilatetime)
    im1=imread(im_shadow_path);
    im2=imread(im_org_path);
    res=xor(im1,im2);
    %res=res(:,:,1).*res(:,:,2).*res(:,:,3);
    res=~uint8(res)*255;
    res=res(:,:,1);
    se1=strel('disk',10);
    BW2 = bwareaopen(res,100);
    BW2 = imclearborder(BW2);
    %imshow(BW2);
    
    for i=1:dilatetime
      BW2=imerode(BW2,se1);
      imshow(BW2);
    end
    
    %imshow(BW2);
    %%
    %Find x bounding box.
    x_min=inf; x_max=-inf;
    for i=1:size(BW2,1)
      rowVec_pos=find(BW2(i,:)~=0);
      if (~isempty(rowVec_pos))
          x_now_l=rowVec_pos(1,1);x_now_r=rowVec_pos(1,end);
          if (x_now_l<x_min)
              x_min=x_now_l;
          end

          if (x_now_r>x_max)
              x_max=x_now_r;
          end
      end
    end

    %%
    %Find y bounding box.
    y_min=inf; y_max=-inf;
    for i=1:size(BW2,2)
      colVec_pos=find(BW2(:,i)~=0);
      if (~isempty(colVec_pos))
          y_now_u=colVec_pos(1);y_now_b=colVec_pos(end);
          if (y_now_u<y_min)
              y_min=y_now_u;
          end

          if (y_now_b>y_max)
              y_max=y_now_b;
          end
      end
    end
    
    [height,width]=size(BW2);
    save(feat_path,'x_min','y_min','x_max','y_max','height','width');
    %imshow(BW2);

   bbox=[x_min y_min x_max-x_min y_max-y_min];
%    im1 = insertObjectAnnotation(im1,'rectangle',bbox,'region');
%    imshow(im1);

end

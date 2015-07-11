 out_root_path='feat_boundingbox/';
 video_count=50;
 for i=1:video_count
    boundingbox_path=[out_root_path,sprintf('%06d',i),'_bounding.mat'];  
    load(boundingbox_path);
    flag=0;
    for j=1:size(feat_bdx,2)
       now_struct=feat_bdx{1,j};
       if (now_struct.total>1)
            flag=flag+1;
       end
    end
    
    if (flag>=1)
        disp([num2str(i),'-',num2str(flag)]);
    end
     
 end
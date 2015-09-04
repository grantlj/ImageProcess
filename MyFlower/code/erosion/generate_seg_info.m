 image_seg_path='D:\dataset\oxfordflower102\102segmentations\segmim\';
 image_raw_path='D:\dataset\oxfordflower102\jpg\';
 bdx_out_path='D:\dataset\oxfordflower102\bdx_info_';
 
 %1,4,7,10,13
 %dilatetime=1;
 image_count=8189;
 
 for j=1:5
     dilatetime=3*j-2;
     now_bdx_out_path=[bdx_out_path,'e',num2str(j),'\'];
     parfor i=1:image_count
        image_seg_file=[image_seg_path,'segmim_',sprintf('%05d',i),'.jpg'];  
        image_raw_file=[image_raw_path,'image_',sprintf('%05d',i),'.jpg']; 
        bdx_file=[now_bdx_out_path,'bdx_',sprintf('%05d',i),'.mat'];

        disp(['Handling image:',num2str(i)]);
        if (~exist(bdx_file,'file'))
          do_seg_single_image(image_raw_file,image_seg_file,bdx_file,dilatetime);
        end
     end
 end
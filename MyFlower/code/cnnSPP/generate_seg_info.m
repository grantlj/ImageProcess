 image_seg_path='D:\dataset\oxfordflower102\102segmentations\segmim\';
 image_raw_path='D:\dataset\oxfordflower102\jpg\';
 bdx_out_path='D:\dataset\oxfordflower102\bdx_info\';
 
 image_count=8189;
 
 parfor i=1:image_count
    image_seg_file=[image_seg_path,'segmim_',sprintf('%05d',i),'.jpg'];  
    image_raw_file=[image_raw_path,'image_',sprintf('%05d',i),'.jpg']; 
    bdx_file=[bdx_out_path,'bdx_',sprintf('%05d',i),'.mat'];
    
    disp(['Handling image:',num2str(i)]);
    if (~exist(bdx_file,'file'))
      do_seg_single_image(image_raw_file,image_seg_file,bdx_file);
    end
 end
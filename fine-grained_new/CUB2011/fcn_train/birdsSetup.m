function imdb = birdsSetup(db_root_path)
  %get image mean and image labels.
  global im_width;global im_height;
  image_count=11788;
  load([db_root_path,'/','imagelabels.mat']);
  for i=1:image_count
      im_path=[db_root_path,'images/images/image_',sprintf('%06d',i),'.jpg'];
      seg_path=[db_root_path,'segmentations/segmentations/seg_',sprintf('%06d',i),'.jpg'];
      %im_tmp=imread(im_path);
      %im_tmp=double(imresize(im_tmp,[im_height,im_width]));
      %data_mean=data_mean+im_tmp;  
      imdb.images.im_pathlist{i}=im_path;
      imdb.images.seg_pathlist{i}=seg_path;
      
  end
  imdb.images.labels=labels;                                          %save labels.
  load([db_root_path,'/setid.mat']);
  set=zeros(1,image_count);
  for i=1:image_count
     if (ismember(i,trnid))
         set(i)=1;
     else
         set(i)=3;
     end
  end 
  imdb.images.set=set;
end

% -------------------------------------------------------------------------
function str=esc(str)
% -------------------------------------------------------------------------
str = strrep(str, '\', '\\') ;

end



function []=image_preprocess()
 image_path_file='D:\dataset\CUB_200_2011\images.txt';
 image_bbx_file='D:\dataset\CUB_200_2011\bounding_boxes.txt';
 train_test_split_file='D:\dataset\CUB_200_2011\train_test_split.txt';
 image_class_labels_file='D:\dataset\CUB_200_2011\image_class_labels.txt';
 
 image_root_path='D:\dataset\CUB_200_2011\segmentations\';
 %image_path=importdata(image_path_file);
 load('image_path.mat');
 image_bbx=importdata(image_bbx_file);
 train_test_split=importdata(train_test_split_file);
 image_class_labels=importdata(image_class_labels_file);
 
 image_count=size(image_path,1);
 
%  labels=image_class_labels(:,2)';
%  save('D:\dataset\CUB_200_2011\imagelabels.mat','labels');
 for i=1:image_count
   now_image_file_path=[image_root_path,image_path{i}];
   
   now_image_file_path=strrep(now_image_file_path,'.jpg','.png');
   disp(now_image_file_path);
   output_file_name=[image_root_path,'segmentations\image_',sprintf('%06d',i),'.jpg'];
   im_tmp=imread(now_image_file_path);
   imwrite(im_tmp,output_file_name);
   
   
 end

% trnid=[];tstid=[];
% for i=1:image_count
%     
%    if(train_test_split(i,2)==1)
%        trnid=[trnid,i];
%    else
%        tstid=[tstid,i];
%    end
%    
% end



end
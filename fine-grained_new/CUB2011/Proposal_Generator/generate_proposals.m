function [] = generate_proposals()
%Generate proposals for all images in CUB2011 dataset.
addpath(genpath('SelectiveSearchCodeIJCV\'));

%Selective_Search_Proposal_Root_Path:
selective_search_proposal_root_path='Selective_Search_Proposals/';
%Start iterate classes.

image_root_path='D:\dataset\CUB_200_2011\images\images\';
output_bbx_root_path='D:\dataset\CUB_200_2011\selective_search_bbx_path\';
mkdir(output_bbx_root_path);

image_count=11788;

for j=1:image_count
     %present image.
     boxes_path=[output_bbx_root_path,sprintf('bbox_%06d',j),'.mat'];
     if (~exist(boxes_path,'file'))
         im_path=[image_root_path,sprintf('image_%06d',j),'.jpg'];
         disp(['Now handling image:',im_path]);
         im=imread(im_path); 
         if (size(im,3)==1)
             im(:,:,2)=im(:,:,1);
             im(:,:,3)=im(:,:,2);
         end
         [boxes]=generate_proposal_single_image(im);
         save(boxes_path,'boxes');
     end
  end


end

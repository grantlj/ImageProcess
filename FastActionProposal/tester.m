%%function [] = proposal_main(video_path,bdx_path,out_video_path)
 
video_root_path='FloorGymnastics/';
bdx_root_path='feat_boundingbox_gym/';
out_video_root_path='out_gym/';

video_count=125;

for i=1:video_count
    
    
   video_path=[video_root_path,sprintf('%06d',i),'_gym.avi']; 
   bdx_path=[bdx_root_path,sprintf('%06d',i),'_gym_bounding.mat'];
   if (~exist(bdx_path,'file'))
       bounding_box_extractor(video_path,bdx_path);
   end
   out_video_path=[out_video_root_path,sprintf('%06d',i),'_gym_out.avi'];
   if (~exist(out_video_path,'file'))
     proposal_main(video_path,bdx_path,out_video_path);
   end
end
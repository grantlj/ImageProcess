%%function [] = proposal_main(video_path,bdx_path,out_video_path)
 
video_root_path='test_dataset/';
bdx_root_path='feat_boundingbox/';
out_video_root_path='out/';

video_count=30;

for i=1:video_count
   video_path=[video_root_path,sprintf('%06d',video_count-i+1),'_walk.avi']; 
   bdx_path=[bdx_root_path,sprintf('%06d',video_count-i+1),'_walk_bounding.mat'];
   out_video_path=[out_video_root_path,sprintf('%06d',video_count-i+1),'_walk_out.avi'];
   proposal_main(video_path,bdx_path,out_video_path);
end
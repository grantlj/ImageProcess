function bounding_box_extractor()
  addpath(genpath('poselet'));
  db_root_path='test_dataset/';
  out_root_path='feat_boundingbox/';
  video_count=30;
  for i=02:02
    videopath=[db_root_path,sprintf('%06d',i),'.avi']; 
    boundingbox_path=[out_root_path,sprintf('%06d',i),'_bounding.mat'];
    if (~exist(boundingbox_path,'file'))
      feat_bdx=handle_bdx_with_video_path(videopath);
      save(boundingbox_path,'feat_bdx');
    end
  end


end


function [feat_bdx]=handle_bdx_with_video_path(videopath)
  obj=VideoReader(videopath);
  vidFrames=read(obj);
  numFrames=obj.numberOfFrames;
  
  feat_bdx={};
  for i=1:numFrames
     now_frame=vidFrames(:,:,:,i);
     bdxinfo=bdx_detector(now_frame);
     feat_bdx{i}=bdxinfo;
  end

end
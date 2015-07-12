function bounding_box_extractor(video_path,bdx_path)
  addpath(genpath('Ptoolbox/'));
  
  if (nargin<2)
      db_root_path='FloorGymnastics/';
      out_root_path='feat_boundingbox_gym/';
      video_count=125;
      for i=1:video_count
        videopath=[db_root_path,sprintf('%06d',i),'_gym.avi']; 
        boundingbox_path=[out_root_path,sprintf('%06d',i),'_gym_bounding.mat'];
        if (~exist(boundingbox_path,'file'))
          feat_bdx=handle_bdx_with_video_path(videopath);
          save(boundingbox_path,'feat_bdx');
        end
      end
  else
     feat_bdx=handle_bdx_with_video_path(video_path);  
     save(bdx_path,'feat_bdx');
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
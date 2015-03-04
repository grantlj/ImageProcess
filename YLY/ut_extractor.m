function ut_extractor()
 addpath(genpath('VideoUtils_1_2_4'));
 ut_set_path={'WEB_interaction_v2.0/chase/','WEB_interaction_v2.0/exchange_object/',...
              'WEB_interaction_v2.0/handshake/','WEB_interaction_v2.0/highfive/',...
              'WEB_interaction_v2.0/hug/','WEB_interaction_v2.0/hustle/',...
              'WEB_interaction_v2.0/kick/','WEB_interaction_v2.0/kiss/','WEB_interaction_v2.0/pat/'...
 };  %dataset path.
 feature_set_path={'WI/chase/','WI/exchange_object/',...
              'WI/handshake/','WI/highfive/',...
              'WI/hug/','WI/hustle/',...
              'WI/kick/','WI/kiss/','WI/pat/'};                                     %corresponding feature saving path.
 m=size(ut_set_path,2);
 
 root=GetPresentPath();
 
 for i=1:m
    now_video_set=ut_set_path{i};
    now_feat_set=feature_set_path{i};
    
    t=cd(now_video_set);
    clc;
    allnames=struct2cell(dir);
    [~,n] = size(allnames);
    cd(root);
    
    videoInfo={};
    for j=1:n
      name=allnames{1,j};
      ace=strfind(name,'.avi');
      if (~isempty(strfind(name,'.avi')))                      %traget file.
          videoname=[now_video_set,name];            %video file path.
          featurename=[now_feat_set,strrep(name,'.avi','siftFeature.mat')];  %feture file path.
          extract_sift_feature(videoname,featurename,5);
      end
    
    end%end of j
    
    
 end% end of i

end

function []=extract_sift_feature(videoname,featurename,sampleFrame)
%extract videoname's sift feature with sample rate: sampleFrame.
%The fetaure is saved in feturename.
 tic;
  if (exist(featurename,'file'))
      disp([featurename,' Skippped...']);
  else
      disp(videoname);
      feat_raw=[];
      obj=myvideo(videoname);
      numFrames=getFrameCount(obj);
      for i=1:floor(numFrames/sampleFrame)
         try
             frame=single(rgb2gray(getFrameAt(obj,i*sampleFrame)));
             [~,d]=vl_sift(frame);
             feat=d;
             feat_raw{i}=feat;
        catch
              disp(['***Error Occur when handling frame:',num2str(i*sampleFrame)]);
        end
      end
      
      save(featurename,'feat_raw');
      
  end
  toc;
end


function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
disp(p1);
i=findstr(p1,'/');
if (isempty(i))         %Differ between Linux and Win
    i=findstr(p1,'\');
end
disp(i);
p1=p1(1:i(end));
res=p1;
end
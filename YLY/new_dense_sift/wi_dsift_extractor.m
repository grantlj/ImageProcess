function wi_dsift_extractor()
 addpath(genpath('VideoUtils_1_2_4'));
 try
     addpath(genpath('VLFEATROOT'));
     vl_setup;
 catch
 end
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
 
  for i=m:-1:1
    
    now_video_set=ut_set_path{i};
    now_feat_set=feature_set_path{i};
    
    
    t=cd(now_video_set);
    clc;
    allnames=struct2cell(dir);
    [~,n] = size(allnames);
    cd(root);
    
    mkdir(now_feat_set);
    
    videoInfo={};
    for j=1:n
      name=allnames{1,j};
      ace=strfind(name,'.avi');
      if (~isempty(strfind(name,'.avi')))                      %traget file.
          videoname=[now_video_set,name];            %video file path.
          featurename=[now_feat_set,strrep(name,'.avi','-DSIFT-Feature.mat')];  %feture file path.
          extract_DSIFT_feature(videoname,featurename,15);
      end
    
    end%end of j
    
    
 end% end of i
 
end

function []=extract_DSIFT_feature(videoname,featurename,sampleFrame)
%extract videoname's dense sift feature with sample rate: sampleFrame.
%The fetaure is saved in feturename.
cellSize = 4;
 tic;
  if (exist(featurename,'file'))
      disp([featurename,' Skippped...']);
  else
      disp(videoname);
      
      obj=myvideo(videoname);
      numFrames=getFrameCount(obj);
      
      total=0;
      
      for i=1:floor(numFrames/sampleFrame)
       try 
            disp(['Frame:',num2str(i*sampleFrame)]);
            tic;
            frame=single(rgb2gray(imresize(getFrameAt(obj,i*sampleFrame),[320 480])));
             
             [f d]=vl_dsift(frame,'size',cellSize);
             toc;
             if (i==1) ,feat=d; else
             feat=feat+d;
             end
             total=total+1;
      catch
              disp(['***Error Occur when handling frame:',num2str(i*sampleFrame)]);
       end
      end
      feat=feat./total;
      save(featurename,'feat');
      
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
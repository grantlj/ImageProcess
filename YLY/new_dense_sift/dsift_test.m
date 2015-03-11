function []=dsift_test()
addpath(genpath('VideoUtils_1_2_4'));
extract_DSIFT_feature('test.avi','test.mat',15);
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
      feat_raw=[];
      obj=myvideo(videoname);
      numFrames=getFrameCount(obj);
      for i=1:floor(numFrames/sampleFrame)
      %   try
            disp(['Frame:',num2str(i*sampleFrame)]);
             tic;
             frame=single(rgb2gray(imresize(getFrameAt(obj,i*sampleFrame),[320 480])));
             
             [f d]=vl_dsift(frame,'size',cellSize);
             toc;
             feat=d;
             feat_raw{i}=feat;
      %  catch
              disp(['***Error Occur when handling frame:',num2str(i*sampleFrame)]);
       % end
      end
      
      save(featurename,'feat_raw');
      
  end
  toc;
end
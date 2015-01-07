function []=getfeat_single_video(videopath)
  addpath(genpath('VideoUtils_1_2_4'));
  if (nargin<1)
    videopath='dataset/wave/_I_ll_Just_Wave_My_Hand__sung_by_Cornerstone_Male_Choir_wave_u_cm_np1_fr_med_0.avi';
  end;
 disp(['Now handling:',videopath]); 

%  obj=VideoReader(videopath);  
%  vidFrames=read(obj);     
%  numFrames=obj.numberOfFrames;
obj=myvideo(videopath);
numFrames=getFrameCount(obj); 

 feat_raw=[]; 
  for i=1:floor(numFrames/5)
      disp(['***Get feat of frame:',num2str(i*5)]);
      %mov(i).cdata=vidFrames(:,:,:,i*5);   
      try
        mov(i).cdata=getFrameAt(obj,i*5);
     
     % imwrite(mov(i).cdata,[num2str(i),'.jpg']);
        feat=getfeat_single_image(mov(i).cdata);
        feat_raw=[feat_raw;feat];
      catch
          disp(['***Error Occur when handling frame:',num2str(i*5)]);
      end
      
   end  
   feature=mean(feat_raw);
   save([videopath,'-Feature.mat'],'feature','feat_raw');
   disp(['Finish handling:',videopath]);
  end
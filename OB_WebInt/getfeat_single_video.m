function []=getfeat_single_video(datapath,videoid,out_path)
%   if (nargin<1)
%     videopath='test.avi';
%   end;


 disp(['Now handling:',num2str(videoid),'  under path;',datapath,'   output path:',out_path]); 
 if (~exist([out_path,sprintf('%06d',videoid),'-Feature.mat'],'file'))

       %  root=GetPresentPath();
        %  obj=VideoReader(videopath);  
        %  vidFrames=read(obj);     
        %  numFrames=obj.numberOfFrames;
        videopath=[datapath,sprintf('%06d',videoid),'.avi'];
        %cd(videopath);
        
        obj=myvideo(videopath);
        numFrames=getFrameCount(obj); 


         feat_raw=[]; 
         for i=1:floor(numFrames/10)
           disp(['***Get feat of frame:',num2str(i*10)]);
           %mov(i).cdata=vidFrames(:,:,:,i*5);   
          try
             mov(i).cdata=getFrameAt(obj,i*10);
     
             % imwrite(mov(i).cdata,[num2str(i),'.jpg']);
             feat=getfeat_single_image(mov(i).cdata);
             feat_raw=[feat_raw;feat];
          catch
            disp(['***Error Occur when handling frame:',num2str(i*5)]);
          end
      
         end  

         feature_max=max(feat_raw);
         feature_min=min(feat_raw);
         feature_mean=mean(feat_raw);
    %     feat_lag=lagrange_opt(feat_raw);

         save([out_path,sprintf('%06d',videoid),'-Feature.mat'],'feature_max','feat_raw','feature_min','feature_mean');
         disp(['Finish handling:',videopath]);
 end
end

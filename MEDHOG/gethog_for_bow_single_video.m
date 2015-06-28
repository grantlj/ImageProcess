function [extracted_feat]=gethog_for_bow_single_video(videoid,out_path)
 disp(['Now extracting HOG for BoW:',num2str(videoid),'  under output path;',out_path]); 
 extracted_feat=[];
 featpath=[out_path,num2str(videoid),'-HOG_RAW_Feature.mat'];
 load(featpath);
 
 frame_count=size(feat_raw,2);
 
 for i=1:frame_count
   now_frame_feat=feat_raw{i};
   
   if (isempty(now_frame_feat))
       continue;
   end
   
   %reshape
   now_frame_feat=reshape(now_frame_feat,size(now_frame_feat,1)*size(now_frame_feat,2),31);
   now_frame_feat_size=size(now_frame_feat,1);
   index_to_extract=randperm(now_frame_feat_size);
   index_to_extract=index_to_extract(1:floor(now_frame_feat_size)*0.05);
   extracted_feat=[extracted_feat;now_frame_feat(index_to_extract,:)];
     
 end
 disp(['Now handling:',num2str(videoid),'  HOG extraction finished']); 
 
end
% %Get present path.
% function res=GetPresentPath()
% clc;
% p1=mfilename('fullpath');
% disp(p1);
% i=findstr(p1,'/');
% if (isempty(i))         %Differ between Linux and Win
%     i=findstr(p1,'\');
% end
% disp(i);
% p1=p1(1:i(end));
% res=p1;
% end
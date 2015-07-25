function []=getfeat_single_video(datapath,videoid,out_path)
%   if (nargin<1)
%     videopath='test.avi';
%   end;
 disp(['Now handling:',num2str(videoid),'  under path;',datapath,'   output path:',out_path]); 
 if (~exist([out_path,num2str(videoid),'-GAO_Feature.mat'],'file'))

         root=GetPresentPath();
        %  obj=VideoReader(videopath);  
        %  vidFrames=read(obj);     
        %  numFrames=obj.numberOfFrames;
        videopath=[datapath,'HVC',num2str(videoid),'/'];
        cd(videopath);



         feat_raw=[]; 
         tmp_jpgfile=struct2cell(dir);
         tmp_jpgfile=tmp_jpgfile(1,:);

         cd(root);
         total=0;

         parfor i=1:size(tmp_jpgfile,2)
            if (~isempty(strfind(tmp_jpgfile{1,i},'-2.jpg')))
                total=total+1;
                tmp_im=imread([videopath,tmp_jpgfile{1,i}]);
                feat=getfeat_single_image(tmp_im);
                feat_raw(i,:)=feat;
            end
         end

         feature_max=max(feat_raw);
         feature_min=min(feat_raw);
         feature_mean=mean(feat_raw);
         feat_lag=lagrange_opt(feat_raw);

         save([out_path,num2str(videoid),'-GAO_Feature.mat'],'feature_max','feat_raw','feature_min','feature_mean','feat_lag');
         disp(['Finish handling:',videopath]);
 end
end
%Get present path.
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
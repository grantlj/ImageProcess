
function [bdxinfo]=bdx_detector(img)

load('AcfInriaDetector.mat'); % model
bbs=acfDetect(img,detector);
bbs=bbNms(bbs);

bdxinfo.total=size(bbs,1);
bdxinfo.score=bbs(:,5);
bdxinfo.bounds=floor(bbs(:,1:4))';
bdxinfo.colorhist=[];

if (bdxinfo.total>0)
    disp(['bounding box found...',num2str(bdxinfo.total)]);
end

for i=1:bdxinfo.total
   x=max(1,bdxinfo.bounds(1,i));y=max(1,bdxinfo.bounds(2,i));w=bdxinfo.bounds(3,i);h=bdxinfo.bounds(4,i);
   if (x+w>size(img,2))
       w=size(img,2)-x;
   end
   
   if (y+h>size(img,1))
       h=size(img,1)-y;
   end
   
   bdxinfo.bounds(1,i)=x;bdxinfo.bounds(2,i)=y;bdxinfo.bounds(3,i)=w;bdxinfo.bounds(4,i)=h;
   im_patch=img(y:y+h,x:x+w,:);
   [hist_r,~]=imhist(im_patch(:,:,1));
   [hist_g,~]=imhist(im_patch(:,:,2));
   [hist_b,~]=imhist(im_patch(:,:,3));

   hist_r=hist_r./max(hist_r);
   hist_g=hist_g./max(hist_g);
   hist_b=hist_b./max(hist_b);

   bdxinfo.colorhist(:,i)=[hist_r;hist_g;hist_b];
end
%end


end


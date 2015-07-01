function [feat]=getfeat_single_image(im)
 feat = vl_hog(single(im),8) ; 
 if (isempty(feat))
     pause;
 end
 % size(feat)
 % pause;
end



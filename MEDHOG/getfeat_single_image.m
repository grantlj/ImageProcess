function [feat]=getfeat_single_image(im)
 feat = vl_hog(single(im),12) ; 
 % size(feat)
 % pause;
end



function [feat]=getfeat_single_image(im)
 [f d]=vl_sift(single(rgb2gray(im)));
 feat=d;
end



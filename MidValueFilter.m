function []=MidValueFilter(filename)
  l_origin=imread(filename);
  l_origin=rgb2gray(l_origin);
  l_noise=imnoise(l_origin,'salt & pepper',0.1);
  subplot(1,3,1);
  imshow(l_origin);
  
  subplot(1,3,2);
  imshow(l_noise);
  
  subplot(1,3,3);
  l_new=medfilt2(l_noise,[5 5]);
  imshow(l_new);
end

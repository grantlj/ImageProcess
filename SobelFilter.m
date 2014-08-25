function []=SobelFilter(filename)
  l_origin=imread(filename);
  l_bw=im2bw(l_origin,graythresh(l_origin));
  subplot(1,2,1);
  imshow(l_bw);
  
  h=fspecial('sobel');
  l_new=imfilter(l_bw,h);
  subplot(1,2,2);
  imshow(l_new);
end
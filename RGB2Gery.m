function []=MYRGB2GREY(filename)
  rgbInstance=imread(filename);
  greyInstance=rgb2gray(rgbInstance);
  subplot(2,2,1);
  imshow(rgbInstance);
  subplot(2,2,2);
  imshow(greyInstance,[0 32]);
  subplot(2,2,3);
  imshow(greyInstance,[32 128]);
  subplot(2,2,4);
  imshow(greyInstance,[0 128]);
  
end
function []=RobertShapening(filename)
  l_origin=imread(filename);
  l_gray=rgb2gray(l_origin);
  
  %Robert Gradient.
  w1=[-1 0;0 1];
  w2=[0 -1;1 0];
  l_new1=imfilter(l_gray,w1,'corr','replicate');
  l_new2=imfilter(l_gray,w2,'corr','replicate');
  
  subplot(1,4,1);
  imshow(l_gray);
  xlabel('The origin one');
  
  subplot(1,4,2);
  imshow(l_new1);
  xlabel('By Gradient 1');
  
  subplot(1,4,3);
  imshow(l_new2);
  xlabel('By Gradient 2');
  
  subplot(1,4,4);
  l_all_new=abs(l_new1)+abs(l_new2);
  imshow(l_all_new);
  xlabel('Composed');
end
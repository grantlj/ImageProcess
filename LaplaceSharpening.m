function []=LaplaceSharpening(filename)
l_origin=imread(filename);
l_gray=rgb2gray(l_origin);
  
  %Laplace Gradiant.
  w=[0 1 0;1 -4 1;0 1 0];
  l_new=imfilter(l_gray,w);
  
  subplot(1,2,1);
  imshow(l_gray);
  xlabel('The origin one');
  
  subplot(1,2,2);
  imshow(l_new);
  xlabel('By Laplace 1');
 
end
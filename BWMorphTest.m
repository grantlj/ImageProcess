function []=BWMorphTest(filename)
 filename='D:\test.jpg';  
l=im2bw(imread(filename),0.85);
 
  l_bridge=bwmorph(l,'remove',inf);
  figure;
  imshow(l);
  figure;
  imshow(l_bridge);
end
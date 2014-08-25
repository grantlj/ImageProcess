function []=HistUniformExperiment(filename)
  
  figure;
  subplot(1,2,1);

  l_origin=rgb2gray(imread(filename));
  [x counts]=imhist(l_origin);
  stem(counts,x);
  
  subplot(1,2,2);
  imshow(l_origin);
  
  figure;
  subplot(1,2,1);
  l_matlab=histeq(l_origin);
  [x counts]=imhist(l_matlab);
  stem(counts,x);
  
  subplot(1,2,2);
  imshow(l_matlab);
  
  figure;
  subplot(1,2,1);
  l_self=zeros(size(l_origin));
  l_self=double(l_self);
  
  maxVal=max(max(l_origin));
  minVal=min(min(l_origin));
  
  [M,N]=size(l_self);

  l_self=(l_origin-minVal)./(maxVal-minVal);
  
  [x counts]=imhist(l_matlab);
  stem(counts,x);
  
  subplot(1,2,2);
  imshow(l_self*255,[]);
  
  
end
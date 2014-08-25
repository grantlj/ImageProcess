

function []=getHistAndBW(filename)

function [counts,x]=getUniHist(image,de)
  [counts,x]=imhist(image,de);
  counts=counts/M/N;
end

  l=imread(filename);
 
  [M,N]=size(l);   %获得大小
  subplot(3,2,1);  
  imshow(l);       %显示原图
  subplot(3,2,2);
  
  [counts,x]=getUniHist(rgb2gray(l),32);
  stem(x,counts);
  
  subplot(3,2,3);
  l_gray=rgb2gray(l);
  imshow(l_gray);
  
  subplot(3,2,4);
  [counts,x]=getUniHist(l_gray,32);
  stem(x,counts);
  
  subplot(3,2,5);
  imshow(im2bw(l));
  
  
end
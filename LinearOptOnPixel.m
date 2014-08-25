function []=LinearOptOnPixel(filename)
 
  l_origin=imread(filename);
  l_gray=rgb2gray(l_origin);
 
  [M,N]=size(l_gray);
  l_gray_rev=zeros(M,N);
  l_gray_rev=double(l_gray_rev);
  
  subplot(2,2,1);
  imshow(l_gray);
  
  subplot(2,2,2);
  [count,x]=imhist(l_gray);
  stem(x,count/M/N); 
  l_gray=double(l_gray);

  
  for i=1:M
      for j=1:N
         %l_gray_rev(i,j)=l_gray(i,j).*(-1)+255;          %Linear Opertion
          l_gray_rev(i,j)=10*log(l_gray(i,j)+3);          %Log Operation
         %disp(['orginal(',num2str(i),',',num2str(j),')=',num2str(l_gray(i,j))]);
         %disp(['rev(',num2str(i),',',num2str(j),')=',num2str(l_gray_rev(i,j))]);
      end
  end

 
  
  
  
  subplot(2,2,3);
  imshow(l_gray_rev,[]);
  
  subplot(2,2,4);
  [count,x]=imhist(l_gray_rev);
  stem(x,count/M/N);
  
end
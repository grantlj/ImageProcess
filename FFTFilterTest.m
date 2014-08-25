function []=FFTFilterTest(filename)
  l_gray=rgb2gray(imread(filename));
  l_freq=fft2(l_gray);
  l_freq=fftshift(fft2(l_gray));  %移动完成后 直流分量在图片的中心位置
  
  subplot(2,2,1);
  imshow(l_gray);
  xlabel('原图');
  
  subplot(2,2,2);
  imshow(log(abs(l_freq)),[]);
  xlabel('频谱');
  
  [m,n]=size(l_freq);
  for i=1:m
      for j=1:n
          if ( sqrt((i-m/2)^2+(j-n/2)^2) <40 ) %把低频部分设置为0
              l_freq(i,j)=0;
          end
      end
  end
  
  subplot(2,2,3);
  imshow(log(abs(l_freq)),[]);
  xlabel('滤波后频谱');
  
  l_new=ifft2(l_freq);

  subplot(2,2,4);
  imshow(255-log(l_new),[]);
  xlabel('滤波后原图');
  
end
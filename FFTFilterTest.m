function []=FFTFilterTest(filename)
  l_gray=rgb2gray(imread(filename));
  l_freq=fft2(l_gray);
  l_freq=fftshift(fft2(l_gray));  %�ƶ���ɺ� ֱ��������ͼƬ������λ��
  
  subplot(2,2,1);
  imshow(l_gray);
  xlabel('ԭͼ');
  
  subplot(2,2,2);
  imshow(log(abs(l_freq)),[]);
  xlabel('Ƶ��');
  
  [m,n]=size(l_freq);
  for i=1:m
      for j=1:n
          if ( sqrt((i-m/2)^2+(j-n/2)^2) <40 ) %�ѵ�Ƶ��������Ϊ0
              l_freq(i,j)=0;
          end
      end
  end
  
  subplot(2,2,3);
  imshow(log(abs(l_freq)),[]);
  xlabel('�˲���Ƶ��');
  
  l_new=ifft2(l_freq);

  subplot(2,2,4);
  imshow(255-log(l_new),[]);
  xlabel('�˲���ԭͼ');
  
end
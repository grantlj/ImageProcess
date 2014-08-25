function EdgeDetectorCompare(filename)
  l_origin=rgb2gray(imread(filename));
  
  l_gaus=imfilter(l_origin,fspecial('gaussian',5,0.4));
  
  l_sobel=edge(l_origin,'sobel');
  l_prewitt=edge(l_origin,'prewitt');
  l_reberts=edge(l_origin,'roberts');
  l_canny=edge(l_origin,'canny');
  
  figure;
  
  subplot(2,3,1);
  imshow(l_origin);
   subplot(2,3,2);
  imshow(l_gaus);
   subplot(2,3,3);
  imshow(l_sobel);
   subplot(2,3,4);
  imshow(l_prewitt);
   subplot(2,3,5);
  imshow(l_reberts);
   subplot(2,3,6);
  imshow(l_canny);
end
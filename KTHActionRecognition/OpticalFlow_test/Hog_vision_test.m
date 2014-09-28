%使用Vision Toolbox获取Hog信息
function Hog_vision_test()
  I=imread('test3.jpg');
  I=uint8(rgb2gray(I));
  points = detectSURFFeatures(I);
  [featureVector, hogVisualization] = extractHOGFeatures(I,'points',points);
   strongest = points.selectStrongest(50);
   imshow(I); hold on;
   plot(strongest);
  imshow(I);
  hold on;
  plot(hogVisualization);

end


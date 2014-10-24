function [] = CVToolBox_HOGTest()
%测试机器视觉工具箱的HOG提取函数;
I=rgb2gray(imread('D:\test.jpg'));
%[hog1, visualization] = extractHOGFeatures(I,'CellSize',[32 32]);
[hog1, visualization] = extractHOGFeatures(I);
subplot(1,2,1);
imshow(I);
subplot(1,2,2);
plot(visualization);
end


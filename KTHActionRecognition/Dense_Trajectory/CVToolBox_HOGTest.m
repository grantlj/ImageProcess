function [] = CVToolBox_HOGTest()
%���Ի����Ӿ��������HOG��ȡ����;
I=rgb2gray(imread('D:\test.jpg'));
%[hog1, visualization] = extractHOGFeatures(I,'CellSize',[32 32]);
[hog1, visualization] = extractHOGFeatures(I);
subplot(1,2,1);
imshow(I);
subplot(1,2,2);
plot(visualization);
end


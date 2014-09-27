% In this case the feature has 31 dimensions. HOG exists in many variants. 
% VLFeat supports two: the UoCTTI variant (used by default) and the original 
% Dalal-Triggs variant (with 2×2 square HOG blocks for normalization). 
% The main difference is that the UoCTTI variant computes bot directed and 
% undirected gradients as well as a four dimensional texture-energy feature, 
% but projects the result down to 31 dimensions. 
% Dalal-Triggs works instead with undirected gradients only and does not do any compression, 
% for a total of 36 dimension
    
function HOT_test1()
vl_setup;
im=single(rgb2gray(imread('D:\test.jpg')));
disp(size(im));
cellSize=8;
hog=vl_hog(im,cellSize);
%hog=vl_hog(im,cellSize,'verbose');
disp(size(hog));

%显示HOG原始图
imhog = vl_hog('render', hog, 'verbose') ;
clf ; imagesc(imhog) ; colormap gray ;

end

%以下为原始输出，vlfeat的hog函数将每一个小块（cell）的设置为cellSize的正方形
%每一个正方形内做HOG特征，特征向量默认为31个维度
%因此 我们可以看到 （320/8)*(240/8)*31
% 
% vl_hog: image: [320 x 240 x 1]
% vl_hog: descriptor: [40 x 30 x 31]
% vl_hog: number of orientations: 9
% vl_hog: bilinear orientation assignments: no
% vl_hog: variant: UOCTTI
% vl_hog: input type: Image
%     40    30    31
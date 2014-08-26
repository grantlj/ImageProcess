function []=FaceDetectorByGrid()
% 载入图像
Img = imread('D:\test4.jpg');
if ndims(Img) == 3
    I=rgb2gray(Img);
else
    I = Img;
end
BW = im2bw(I, graythresh(I)); % 二值化
figure;
subplot(2, 2, 1); imshow(Img);
title('原图像', 'FontWeight', 'Bold');
subplot(2, 2, 2); imshow(Img);
title('网格标记图像', 'FontWeight', 'Bold');
hold on;
[xt, yt] = meshgrid(round(linspace(1, size(I, 1), 10)), ...
    round(linspace(1, size(I, 2), 10)));
mesh(yt, xt, zeros(size(xt)), 'FaceColor', ...
    'None', 'LineWidth', 3, ...
    'EdgeColor', 'r');
subplot(2, 2, 3); imshow(BW);
title('二值图像', 'FontWeight', 'Bold');
[n1, n2] = size(BW);
r = floor(n1/10); % 分成10块，行
c = floor(n2/10); % 分成10块，列
x1 = 1; x2 = r; % 对应行初始化
s = r*c; % 块面积
 
for i = 1:10
    y1 = 1; y2 = c; % 对应列初始化
    for j = 1:10
        if (y2<=c || y2>=9*c) || (x1==1 || x2==r*10)
            % 如果是在四周区域
            loc = find(BW(x1:x2, y1:y2)==0);
            [p, q] = size(loc);
            pr = p/s*100; % 黑色像素所占的比例数
            if pr <= 100
                BW(x1:x2, y1:y2) = 0;
            end
        end
        y1 = y1+c; % 列跳跃
        y2 = y2+c; % 列跳跃
    end   
    x1 = x1+r; % 行跳跃
    x2 = x2+r; % 行跳跃
end
 
[L, num] = bwlabel(BW, 8); % 区域标记
stats = regionprops(L, 'BoundingBox'); % 得到包围矩形框
Bd = cat(1, stats.BoundingBox);
 
[s1, s2] = size(Bd);
mx = 0;
for k = 1:s1
    p = Bd(k, 3)*Bd(k, 4); % 宽*高
    if p>mx && (Bd(k, 3)/Bd(k, 4))<1.8
        % 如果满足面积块大，而且宽/高<1.8
        mx = p;
        j = k;
    end
end

subplot(2, 2, 4);imshow(I); hold on;
rectangle('Position', Bd(j, :), ...
    'EdgeColor', 'r', 'LineWidth', 3);
title('标记图像', 'FontWeight', 'Bold');


end
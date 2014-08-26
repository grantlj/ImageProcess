function []=FaceDetectorByGrid()
% ����ͼ��
Img = imread('D:\test4.jpg');
if ndims(Img) == 3
    I=rgb2gray(Img);
else
    I = Img;
end
BW = im2bw(I, graythresh(I)); % ��ֵ��
figure;
subplot(2, 2, 1); imshow(Img);
title('ԭͼ��', 'FontWeight', 'Bold');
subplot(2, 2, 2); imshow(Img);
title('������ͼ��', 'FontWeight', 'Bold');
hold on;
[xt, yt] = meshgrid(round(linspace(1, size(I, 1), 10)), ...
    round(linspace(1, size(I, 2), 10)));
mesh(yt, xt, zeros(size(xt)), 'FaceColor', ...
    'None', 'LineWidth', 3, ...
    'EdgeColor', 'r');
subplot(2, 2, 3); imshow(BW);
title('��ֵͼ��', 'FontWeight', 'Bold');
[n1, n2] = size(BW);
r = floor(n1/10); % �ֳ�10�飬��
c = floor(n2/10); % �ֳ�10�飬��
x1 = 1; x2 = r; % ��Ӧ�г�ʼ��
s = r*c; % �����
 
for i = 1:10
    y1 = 1; y2 = c; % ��Ӧ�г�ʼ��
    for j = 1:10
        if (y2<=c || y2>=9*c) || (x1==1 || x2==r*10)
            % ���������������
            loc = find(BW(x1:x2, y1:y2)==0);
            [p, q] = size(loc);
            pr = p/s*100; % ��ɫ������ռ�ı�����
            if pr <= 100
                BW(x1:x2, y1:y2) = 0;
            end
        end
        y1 = y1+c; % ����Ծ
        y2 = y2+c; % ����Ծ
    end   
    x1 = x1+r; % ����Ծ
    x2 = x2+r; % ����Ծ
end
 
[L, num] = bwlabel(BW, 8); % ������
stats = regionprops(L, 'BoundingBox'); % �õ���Χ���ο�
Bd = cat(1, stats.BoundingBox);
 
[s1, s2] = size(Bd);
mx = 0;
for k = 1:s1
    p = Bd(k, 3)*Bd(k, 4); % ��*��
    if p>mx && (Bd(k, 3)/Bd(k, 4))<1.8
        % ������������󣬶��ҿ�/��<1.8
        mx = p;
        j = k;
    end
end

subplot(2, 2, 4);imshow(I); hold on;
rectangle('Position', Bd(j, :), ...
    'EdgeColor', 'r', 'LineWidth', 3);
title('���ͼ��', 'FontWeight', 'Bold');


end
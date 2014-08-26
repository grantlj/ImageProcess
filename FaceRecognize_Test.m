function []=FaceRecognize_Test()
 srcDir='D:\Matlab\Faces\20142151.jpg';
% dstDir='D:\Matlab\Faces\detected\';
transMatDir='D:\Matlab\Faces\transMat.dat';  %存COFF矩阵
dbMatDir='D:\Matlab\Faces\dbMat.dat';        %存数据库 PCA后的得分
meanFaceDir='D:\Matlab\Faces\meanFace.dat';

  totalPho=100;
 % rootFileName='2014';
  scoreTerm=9;              %PCA中取新参考系下的前10个指标作为标准
  global rowC;global colC;  %这是全局变量，matlab中 哪里要用 必须在两个函数中都定义
  rowC=80;colC=100;
  
 samplePCAScore=load(dbMatDir);
 COEFF=load(transMatDir);
 meanFace=load(meanFaceDir);
 
  srcRaw=FaceProcess(srcDir);
  
 % disp(size(srcRaw));
  %disp(size(COEFF));
  
  srcRaw(1,:)=srcRaw(1,:)-meanFace;
  
  srcNew=srcRaw*COEFF(:,1:scoreTerm);
  %srcNew=srcNew(:,1:scoreTerm);
 % disp(size(srcNew));
  
  mindist=inf;
  p=-1;
  for i=1:totalPho
     tmpVct=double(samplePCAScore(i,:));
   %  disp(tmpVct);
     nowDist=double(0);
     for j=1:scoreTerm
         nowDist=nowDist+(tmpVct(j)-srcNew(1,j))^2;
     end
     nowDist=sqrt(nowDist);
     if (nowDist<mindist)
         mindist=nowDist;
         p=i;
     end
  end
  disp(mindist);
  disp(p);
end



function [srcRaw]=FaceProcess(srcDir)
% 载入图像
   global rowC;global colC;  %这里也要声明 以下的rowC和colC是全局的
   srcRaw=double(zeros(1,rowC*colC));
   
Img = imread(srcDir);
if ndims(Img) == 3
    I=rgb2gray(Img);
else
    I = Img;
end
BW = im2bw(I, graythresh(I)); % 二值化
BW=medfilt2(BW,[2,2]);      %中值滤波 降噪

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
stats = regionprops(L, 'BoundingBox'); % 得到包围矩形框  x,y width height
Bd = cat(1, stats.BoundingBox);
 
[s1, s2] = size(Bd);
mx = 0;
for k = 1:s1
    p = Bd(k, 3)*Bd(k, 4); % 宽*高
    if p>mx && (Bd(k, 3)/Bd(k, 4))<1.8
        % 如果满足面积块大，而且宽/高<1.8
        mx = p;
        j2 = k;
    end
end


ret=round(Bd(j2,1:4));
I_face=uint8(zeros(ret(4),ret(3)));
for i=1:ret(4)                        %column
    for j=1:ret(3)                    %row
        I_face(i,j)=I(ret(2)+i-1,ret(1)+j-1);
        
    end
end

I_face=imresize(I_face,[rowC,colC]);


for i=1:rowC
    for j=1:colC
        srcRaw(1,(i-1)*rowC+j)=I_face(i,j);
    end

end
disp('Finishing calculating');
end

function []=FaceRecognize_Test()
 srcDir='D:\Matlab\Faces\20142151.jpg';
% dstDir='D:\Matlab\Faces\detected\';
transMatDir='D:\Matlab\Faces\transMat.dat';  %��COFF����
dbMatDir='D:\Matlab\Faces\dbMat.dat';        %�����ݿ� PCA��ĵ÷�
meanFaceDir='D:\Matlab\Faces\meanFace.dat';

  totalPho=100;
 % rootFileName='2014';
  scoreTerm=9;              %PCA��ȡ�²ο�ϵ�µ�ǰ10��ָ����Ϊ��׼
  global rowC;global colC;  %����ȫ�ֱ�����matlab�� ����Ҫ�� ���������������ж�����
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
% ����ͼ��
   global rowC;global colC;  %����ҲҪ���� ���µ�rowC��colC��ȫ�ֵ�
   srcRaw=double(zeros(1,rowC*colC));
   
Img = imread(srcDir);
if ndims(Img) == 3
    I=rgb2gray(Img);
else
    I = Img;
end
BW = im2bw(I, graythresh(I)); % ��ֵ��
BW=medfilt2(BW,[2,2]);      %��ֵ�˲� ����

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
stats = regionprops(L, 'BoundingBox'); % �õ���Χ���ο�  x,y width height
Bd = cat(1, stats.BoundingBox);
 
[s1, s2] = size(Bd);
mx = 0;
for k = 1:s1
    p = Bd(k, 3)*Bd(k, 4); % ��*��
    if p>mx && (Bd(k, 3)/Bd(k, 4))<1.8
        % ������������󣬶��ҿ�/��<1.8
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

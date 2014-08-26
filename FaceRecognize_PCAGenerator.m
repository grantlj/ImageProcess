

 
function []=FaceRecognize_PCAGenerator()
  srcDir='D:\Matlab\Faces\';
  dstDir='D:\Matlab\Faces\detected\';
 transMatDir='D:\Matlab\Faces\transMat.dat';  %��COFF����
dbMatDir='D:\Matlab\Faces\dbMat.dat';        %�����ݿ� PCA��ĵ÷�
  meanFaceDir='D:\Matlab\Faces\meanFace.dat';  %�洢ƽ����
  totalPho=100;
  rootFileName='2014';
  scoreTerm=9;              %PCA��ȡ�²ο�ϵ�µ�ǰ10��ָ����Ϊ��׼
   global rowC;global colC;  %����ȫ�ֱ�����matlab�� ����Ҫ�� ���������������ж�����
   rowC=80;colC=100;
   global fullInfo;
   
   fullInfo=zeros(totalPho,rowC*colC); %ԭ���� ��������ԭʼͷ��ÿ����ĻҶ� ����Ϊ֮���PCA��׼��
   
  samplePCAScore=double(zeros(totalPho,scoreTerm)); %����PCA֮��ľ�������Ҫ��������浽�ļ���
  COEFF=double(zeros(rowC*colC,rowC*colC));         %COEFF���� ����˵����ԭ�����²ο�ϵ�����ֵ �ı任��ʽ
  

  
  for i=1:totalPho
     if (i<=9)
         z='000';
     else if (i<=99)
          z='00';
         else if (i<=999)
                 z='0';
             end
         end
     end
     
    
     tmpSrcFile=[srcDir,rootFileName,z,num2str(i),'.jpg'];
     tmpDstFile=[dstDir,rootFileName,z,num2str(i),'dec.jpg'];
     if (exist(tmpSrcFile,'file'))
       FaceProcess(tmpSrcFile,tmpDstFile,i);
     end
  end
  
  meanFace=double(mean(fullInfo));  %ƽ���� �������й�һ������
  for i=1:totalPho
      fullInfo(i,:)=fullInfo(i,:)-meanFace;
  end
  
  [COEFF,SCORE]=princomp(fullInfo);          %PCA����
  samplePCAScore=SCORE(:,1:scoreTerm);
  save(transMatDir,'COEFF','-ascii');
  save(dbMatDir,'samplePCAScore','-ascii');
  save(meanFaceDir,'meanFace','-ascii');
  
  %save transMatDir COEFF -ascii;
  %save dbMatDir samplePCAScore -ascii;
  disp('Finished');
  
  %disp(samplePCAScore);
%  disp(COEFF);
  
end

function []=FaceProcess(tmpSrcFile,tmpDstFile,nownum)
disp(nownum);
% ����ͼ��
   global rowC;global colC;  %����ҲҪ���� ���µ�rowC��colC��ȫ�ֵ�
   global fullInfo;
   
Img = imread(tmpSrcFile);
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

figure('visible','off');
ret=round(Bd(j2,1:4));
I_face=uint8(zeros(ret(4),ret(3)));

for i=1:ret(4)                        %column
    for j=1:ret(3)                    %row
        I_face(i,j)=I(ret(2)+i-1,ret(1)+j-1);
        
    end
end

I_face=imresize(I_face,[rowC,colC]);
imshow(I_face); hold on;

for i=1:rowC
    for j=1:colC
        fullInfo(nownum,(i-1)*rowC+j)=I_face(i,j);
    end
end


saveas_center(gcf,tmpDstFile,rowC,colC);
end

%���ֱ��淽��������������figure�����İױ�
function []=saveas_center(h, save_file, width, height)
% saveas_center(h, save_file, width, height)

set(0,'CurrentFigure',h);

set(gcf,'PaperPositionMode','auto');
set(gca,'position',[0,0,1,1]);
set(gcf,'position',[1,1,width,height]);

saveas(h, save_file);
end
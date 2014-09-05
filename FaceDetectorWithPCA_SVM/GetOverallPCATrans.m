function []=GetOverallPCATrans(path)

 COEFFMatDir='D:\Matlab\MITFace\COEFF.dat';  %��COFF����
 meanFaceDir='D:\Matlab\MitFace\meanFace.dat';%�洢ƽ����
   t = cd(path);                        % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);   % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  for i= 3:n                           % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}         %  ���ȡ���ļ���
     if (findstr(name,'.bmp')>=1)
        filename=[t,'\',name]        %   ����ļ���
        fileInfo=[fileInfo;filename];
     end
  end
  clc;
  
  h=20;w=20;   %ʶ����У��߿��Ϊ20
  phoCount=size(fileInfo,1);
  fullInfo=zeros(phoCount,h*w);
  COEFF=double(zeros(h*w,h*w)); 
  for i=1:phoCount
    file=fileInfo{i};
    tmp=imread(file);
      for j=1:h
        for k=1:w
          fullInfo(i,(j-1)*h+k)=tmp(j,k);
        end
      end
  end
  
  meanFace=double(mean(fullInfo));  %ƽ��ͼ �������й�һ������
%  ��ʾƽ��������������
%   newFace=uint8(zeros(h,w));
%   for i=1:h
%       for j=1:w
%           newFace(i,j)=meanInfo((i-1)*h+j);
%       end
%   end
%   figure;
%   imshow(newFace);
  
  for i=1:phoCount
      fullInfo(i,:)=fullInfo(i,:)-meanFace;
  end
  [COEFF,SCORE]=princomp(fullInfo);    
  
  %select top 35 to save.
  disp('Ready to save COEFF and meanFace');
  save(COEFFMatDir,'COEFF','-ascii');
  save(meanFaceDir,'meanFace','-ascii');
% save COEFFMat.dat  COEFF;
 %save meanFaceMat.dat meanFace;

end
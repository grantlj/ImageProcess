function [] = GenerateFacePCAScore()
 COEFFMatDir='D:\Matlab\MITFace\COEFF.dat';  %��COFF����
 meanFaceDir='D:\Matlab\MitFace\meanFace.dat';%�洢ƽ����
 facePCAScoreDir='D:\Matlab\MitFace\facePCAScore.dat'; %�洢PCA���ֺ����
 path='D:\Matlab\MITFace\faces';
  %COEFF=double(zeros(h*w,h*w)); 
   COEFF=load(COEFFMatDir);        %����ƽ������COEFF�任����
   meanFace=load(meanFaceDir);
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
  fullInfo=zeros(phoCount,h*w);    %����ͼƬԭʼ��Ϣ
  scoreTerm=35;
  fullScore=zeros(phoCount,h*w);    %��ǰ35��
 
   
    for i=1:phoCount
    file=fileInfo{i};
    tmp=imread(file);
      for j=1:h
        for k=1:w
          fullInfo(i,(j-1)*h+k)=tmp(j,k);
        end
      end
      fullInfo(i,:)=fullInfo(i,:)-meanFace;  %��һ������
      fullScore(i,:)=fullInfo(i,:)*COEFF;   %���PCA Score
      disp(['finish:',file]);
    end
    fullScore=fullScore(:,1:35);
   save(facePCAScoreDir,'fullScore','-ascii');
end


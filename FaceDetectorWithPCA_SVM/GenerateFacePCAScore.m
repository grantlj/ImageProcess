function [] = GenerateFacePCAScore()
 COEFFMatDir='D:\Matlab\MITFace\COEFF.dat';  %存COFF矩阵
 meanFaceDir='D:\Matlab\MitFace\meanFace.dat';%存储平均脸
 facePCAScoreDir='D:\Matlab\MitFace\facePCAScore.dat'; %存储PCA评分后的脸
 path='D:\Matlab\MITFace\faces';
  %COEFF=double(zeros(h*w,h*w)); 
   COEFF=load(COEFFMatDir);        %载入平均脸和COEFF变换矩阵
   meanFace=load(meanFaceDir);
 t = cd(path);                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);   % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  for i= 3:n                           % 从3开始。前两个属于系统内部。
     name = allnames{1,i}         %  逐次取出文件名
     if (findstr(name,'.bmp')>=1)
        filename=[t,'\',name]        %   组成文件名
        fileInfo=[fileInfo;filename];
     end
  end
  clc;
  
  h=20;w=20;   %识别库中，高宽均为20
  phoCount=size(fileInfo,1);
  fullInfo=zeros(phoCount,h*w);    %所有图片原始信息
  scoreTerm=35;
  fullScore=zeros(phoCount,h*w);    %存前35个
 
   
    for i=1:phoCount
    file=fileInfo{i};
    tmp=imread(file);
      for j=1:h
        for k=1:w
          fullInfo(i,(j-1)*h+k)=tmp(j,k);
        end
      end
      fullInfo(i,:)=fullInfo(i,:)-meanFace;  %归一化操作
      fullScore(i,:)=fullInfo(i,:)*COEFF;   %完成PCA Score
      disp(['finish:',file]);
    end
    fullScore=fullScore(:,1:35);
   save(facePCAScoreDir,'fullScore','-ascii');
end


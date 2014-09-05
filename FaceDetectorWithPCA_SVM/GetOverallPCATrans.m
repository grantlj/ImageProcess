function []=GetOverallPCATrans(path)

 COEFFMatDir='D:\Matlab\MITFace\COEFF.dat';  %存COFF矩阵
 meanFaceDir='D:\Matlab\MitFace\meanFace.dat';%存储平均脸
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
  
  meanFace=double(mean(fullInfo));  %平均图 用来进行归一化操作
%  显示平均脸，用来测试
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
%使用K-means进行聚类
function [] = GenerateClasses()
  root=(GetPresentPath);
  path='huRAW/';
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';
  
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'.mat')>=1))
        filename=[path,name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
      %  hufileInfo=[hufileInfo;strrep(filename,'.avi','_HU.mat')];
     end
  end
  
  huCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  allData=zeros(1,7);
  
  for i=1:huCount
     file=fileInfo{i};
     load(file);
     huMat=huMat(2:end,:);
     allData=[allData;huMat];
  end
  
%   X N*P的数据矩阵
%   K 表示将X划分为几类，为整数
%   Idx N*1的向量，存储的是每个点的聚类标号
%   C K*P的矩阵，存储的是K个聚类质心位置
%   sumD 1*K的和向量，存储的是类间所有点与该类质心点距离之和
%   D N*K的矩阵，存储的是每个点与所有质心的距离
   allData=double(allData);
   [Idx,C,sumD,D]=kmeans(allData,200,'emptyaction','drop','Replicates',5);
   classInfo.Idx=Idx;classInfo.C=C;classInfo.sumD=D;classInfo.D=D;
   save(classInfoPath,'classInfo');
   
end

function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
disp(p1);
i=findstr(p1,'/');
if (isempty(i))         %Differ between Linux and Win
    i=findstr(p1,'\');
end
disp(i);
p1=p1(1:i(end));
res=p1;
end
 
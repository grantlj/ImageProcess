%ʹ��K-means���о���
function [] = GenerateClasses()
  root=(GetPresentPath);
  path='huRAW/';
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';
  
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'.mat')>=1))
        filename=[path,name];                   %   ����ļ���
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
  
%   X N*P�����ݾ���
%   K ��ʾ��X����Ϊ���࣬Ϊ����
%   Idx N*1���������洢����ÿ����ľ�����
%   C K*P�ľ��󣬴洢����K����������λ��
%   sumD 1*K�ĺ��������洢����������е���������ĵ����֮��
%   D N*K�ľ��󣬴洢����ÿ�������������ĵľ���
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
 
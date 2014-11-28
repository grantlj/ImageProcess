function []=GmmModelVerify()
  path='fvRAW\';
  root=(GetPresentPath);
  
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fvfileInfo={};
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'_FV.mat')>=1) )
     
        filename=[path,name];                   %   组成文件名
        fvfileInfo=[fvfileInfo;filename];
       
     end
  end
  
  fvCount=size(fvfileInfo,1);
  t=cd(root);
  clc;
  load(fvfileInfo{1});
  dim=size(fvVal',2);
  fvs=zeros(fvCount,dim);
  for i=1:fvCount
    load(fvfileInfo{i});
    fvVal=fvVal';
    fvs(i,:)=fvVal(1,:);
  end
  
 %action count;
 actionCount=5;
 %scene count;
 sceneCount=4;
 [PX MODEL] = gmm(fvs, 20);    %first, we clustter by actions!
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
function [] = GeneratorSVMInfo_Spatial()
  path='histRAW\';
  root=(GetPresentPath);
  SVMModel='SVMModel_Spatial.mat';
  
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  histfileInfo={};
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
   %  if ( (findstr(name,'_HIST_SPATIAL.mat')>=1) )
       if ( (findstr(name,'_HIST_SPATIAL.mat')>=1) & (findstr(name,'d4')>=1))
        filename=[path,name];                   %   组成文件名
        histfileInfo=[histfileInfo;filename];
       
     end
  end
  
  histCount=size(histfileInfo,1);
  t=cd(root);
  clc;
  histfileInfo= histfileInfo(randperm(length(histfileInfo)));
  tag=double(zeros(1,histCount));
  hists=[];
  for i=1:round(histCount)
      file=histfileInfo{i};
      if (strfind(file,'boxing')) tag(i)=1; end
      if (strfind(file,'handclapping')) tag(i)=2; end
      if (strfind(file,'jogging')) tag(i)=3;end
      if (strfind(file,'running')) tag(i)=4;end
      if (strfind(file,'walking')) tag(i)=5;end    
      load(histfileInfo{i});
%    maxVal=max(histVal);minVal=min(histVal);
%    histVal=(histVal-minVal)./(maxVal-minVal);
      hists=[hists;histVal];
  end
  tag=tag';
  
  %网格法参数寻优
  
% [bestCVaccuracy,bestc,bestg]=SVMcgForClass(tag,hists,-9,9,-9,9,size(tag,1),1,1,6);
%参数调优后 c=4 g=4
 model=svmtrain(tag,hists,'-s 1 -t 2 -g 0.125');  %V-svc
% model=svmtrain(tag,hists,'-s 1');  %V-svc

 save(SVMModel,'model');

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
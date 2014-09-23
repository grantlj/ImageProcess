function [] =GenerateCandidateHists()
  path='ClassCandidate\';
  root=(GetPresentPath);
   t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  
   for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'ClassInfo.mat')>=1))
        filename=[path,name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
     end
   end
  
  candCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  for i=1:candCount
      load(fileInfo{i});
      disp(fileInfo{i});
      classes=size(classInfo.C,1);
      count=zeros(1,classes);
      for j=1:size(classInfo.Idx,1)
          count(classInfo.Idx(j))=count(classInfo.Idx(j))+1;
      end
      disp([num2str(i),':',fileInfo{i},', VAR=',num2str(var(count))]);
      figure('visible','off');
      bar(count);
      title(fileInfo{i});
      saveas_center(gcf,[num2str(i),'.jpg'],800,600);
  end
  
end

function []=saveas_center(h, save_file, width, height)
% saveas_center(h, save_file, width, height)

set(0,'CurrentFigure',h);

set(gcf,'PaperPositionMode','auto');
set(gca,'position',[0,0,1,1]);
set(gcf,'position',[1,1,width,height]);

saveas(h, save_file);
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
 
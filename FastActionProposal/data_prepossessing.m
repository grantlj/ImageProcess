function []=data_prepossessing()
%filename transfer.
transfer_file_name('FloorGymnastics/');


end

function transfer_file_name(path)
root=(GetPresentPath);
t = cd(path);                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
[m,n] = size(allnames);
fileInfo={};
for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'.avi')>=1))
        filename=[name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
     end
end

jpgCount=size(fileInfo,1);

clc;
for i=1:jpgCount
  %eval(['!rename', [',',fileInfo{i}] [',image_',sprintf('%04d',i),'.jpg']]);
  %im=imread(fileInfo{i});
  %imwrite(im,['image_',sprintf('%04d',i),'.jpg
  copyfile(fileInfo{i},[sprintf('%06d',i),'_gym.avi']);
  delete(fileInfo{i});
end

t=cd(root);
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

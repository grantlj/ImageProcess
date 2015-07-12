function []=data_prepossessing()
%filename transfer.
transfer_file_name('FloorGymnastics/');


end

function transfer_file_name(path)
root=(GetPresentPath);
t = cd(path);                        % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
[m,n] = size(allnames);
fileInfo={};
for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'.avi')>=1))
        filename=[name];                   %   ����ļ���
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

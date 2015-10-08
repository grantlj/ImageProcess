function []=data_prepossessing()
neg_path='D:/dataset/HLeaf/normal/';
pos_path='D:/dataset/HLeaf/abnormal/';
extra_path='D:/dataset/HLeaf/other/20150926/';

%filename transfer.

%transfer_file_name(neg_path);
%transfer_file_name(pos_path);
transfer_file_name(extra_path);
%data_mean_pos=calculate_mean(pos_path,170);
%data_mean_neg=calculate_mean(neg_path,6427);

data_mean=data_mean_pos;

save('D:/dataset/HLeaf/data_mean.mat','data_mean');
end


function [data_mean]=calculate_mean(path,n)
data_mean=zeros(224,224,3);
  for i=1:n
    file_name=[path,'image_',sprintf('%04d',i),'.jpg'];
    now_im=imread(file_name);
    now_im=double(imresize(now_im,[224 224]));
    data_mean=data_mean+now_im;
  end
  data_mean=data_mean./n;
end

function transfer_file_name(path)
root=(GetPresentPath);
t = cd(path);                        % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
[m,n] = size(allnames);
fileInfo={};
for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     %if ( (findstr(name,'.jpg')>=1) | (findstr(name,'.JPG')>=1))
        filename=[name];                   %   ����ļ���
        fileInfo=[fileInfo;filename];
    % end
end

jpgCount=size(fileInfo,1);

clc;
for i=1:jpgCount
  %eval(['!rename', [',',fileInfo{i}] [',image_',sprintf('%04d',i),'.jpg']]);
  im=imread(fileInfo{i});
  imwrite(im,['image_',sprintf('%04d',i+170),'.jpg']);
  %delete(fileInfo{i});
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

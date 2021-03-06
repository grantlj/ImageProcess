function []=data_prepossessing()
neg_path='D:/dataset/belt_detection/images/belt_free/';
pos_path='D:/dataset/belt_detection/images/belted/';
%vague_path='D:/dataset/belt_detection/images/vague/';
extra_path='D:\dataset\belt_detection\images\belt_testset_1119\';

%filename transfer.

transfer_file_name(extra_path);
%transfer_file_name(pos_path);
%transfer_file_name(neg_path);
%move_file_from_to(vague_path,neg_path,5745,5294); 
%data_mean_pos=calculate_mean(pos_path,15910);
%data_mean_neg=calculate_mean(neg_path,2010);

%data_mean=data_mean_pos;

%save('D:/dataset/belt_detection/data_mean.mat','data_mean');
end


function [data_mean]=calculate_mean(path,n)
data_mean=zeros(100,100,3);
  for i=1:n
    file_name=[path,'image_',sprintf('%05d',i),'.jpg'];
    now_im=imread(file_name);
    now_im=double(imresize(now_im,[100 100]));
    data_mean=data_mean+now_im;
  end
  data_mean=data_mean./n;
end

%%
function move_file_from_to(from_path,to_path,from_count,base_count)
root=(GetPresentPath);
t = cd(from_path);                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
[m,n] = size(allnames);
fileInfo={};
for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     %if ( (findstr(name,'.jpg')>=1) | (findstr(name,'.JPG')>=1))
        filename=[name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
    % end
end

jpgCount=size(fileInfo,1);

clc;
for i=1:jpgCount
  %eval(['!rename', [',',fileInfo{i}] [',image_',sprintf('%04d',i),'.jpg']]);
  im=imread(fileInfo{i});
  imwrite(im,[to_path,'image_',sprintf('%05d',i+base_count),'.jpg']);
 % delete(fileInfo{i});
end

t=cd(root);
end

%%
function transfer_file_name(path)
root=(GetPresentPath);
t = cd(path);                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
[m,n] = size(allnames);
fileInfo={};
for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     %if ( (findstr(name,'.jpg')>=1) | (findstr(name,'.JPG')>=1))
        filename=[name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
    % end
end

jpgCount=size(fileInfo,1);

clc;
for i=1:jpgCount
  %eval(['!rename', [',',fileInfo{i}] [',image_',sprintf('%04d',i),'.jpg']]);
  im=imread(fileInfo{i});
  imwrite(im,['image_',sprintf('%05d',i),'.jpg']);
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

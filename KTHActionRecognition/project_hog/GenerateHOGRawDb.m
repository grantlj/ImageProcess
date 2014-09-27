%产生特定文件夹下所有文件的HOG Info
function [] = GenerateHOGRawDb()
   %文件夹和类型选项，打开相应的注释，生成对应文件夹下的训练集数据
  root=(GetPresentPath);
 %path='boxing/'; 
 %path='handclapping/';
 %path='jogging/';
 %path='running/';  
 path='walking/';
 
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  
  hogfileInfo={};
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'.avi')>=1))
        filename=[path,name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
        hogfileInfo=[hogfileInfo;strrep(filename,'.avi','_HOG.mat')];
     end
  end
  
  aviCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  for i=1:aviCount
      disp(['******File:',fileInfo{i}]);
    
    if (~exist([hogfileInfo{i}],'file'))
        disp('      Generating HOG-RAW...');
        ret=GenerateHOGRawInfo(fileInfo{i});
        save(hogfileInfo{i},'ret');
        disp('   ');
    else
        disp('      HOG-RAW already existed...');
    end
  end
  
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

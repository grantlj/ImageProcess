%Fisher-Vector版本
%利用Vlfeat库，生成GMM模型版本的words

function [] = GenerateClasses()
  vl_setup;
  root=(GetPresentPath);
  path='siftRAW/';
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';

  
  
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'SIFT.mat')>=1))
        filename=[path,name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
     end
  end
  
  siftCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  disp('Loading sift-raw files...');
    
    total=0;
    for i=1:siftCount
      load(fileInfo{i});
     % disp(['Now handling:',num2str(i),'/',num2str(siftCount)]);
     
      for j=1:size(ret,2)
         sgFrame=ret(j).f;
         for k=1:size(sgFrame,2)
           total=total+1;
         end
      end
    end
    disp(total);
    siftRaws=zeros(total,2);
  
  total=0;
  for i=1:siftCount
      load(fileInfo{i});
      disp(['Now handling:',num2str(i),'/',num2str(siftCount)]);
     
      for j=1:size(ret,2)
         sgFrame=ret(j).f;
         for k=1:size(sgFrame,2)
             total=total+1;
             siftRaws(total,1)=sgFrame(3,k);siftRaws(total,2)=sgFrame(4,k);
         end
      end
      
  end
  
  siftRaws=siftRaws';
  words=25;
  [ClassInfo.means, ClassInfo.covariances, ClassInfo.priors] = vl_gmm(siftRaws, words);
  save(classInfoPath,'ClassInfo');
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
 


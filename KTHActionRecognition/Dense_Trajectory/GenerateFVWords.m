%Use fisher-vector and GMM model to generate Dense-MBH words.
function GenerateFVWords()
  vl_setup;
  root=(GetPresentPath);
  path='MBHRAW/';
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='FV_ClassInfo.mat';

  
  
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'MBH.mat')>=1))
        filename=[path,name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
     end
  end
  
  mbhCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  disp('Loading MBH-raw files...');
  total=0;
  for i=1:mbhCount
    load(fileInfo{i});
    total=total+size(ret,1);
  end
  dim=size(ret,2);
  mbhRaws=zeros(total,dim);
  total=0;
  
  for i=1:mbhCount
      load(fileInfo{i});
      disp(['Loading MBH file:',num2str(i)]);
      for j=1:size(ret,1)
          total=total+1;
          mbhRaws(total,:)=ret(j,:);
      end
  end
  rowrank=randperm(size(mbhRaws,1));
  mbhRaws=mbhRaws(rowrank,:);
  mbhRaws=mbhRaws(1:round(size(mbhRaws,1)*0.1),:);
  %随机选择10%的特征进行gmm聚类
  
  mbhRaws=mbhRaws';
  words=80;
  [ClassInfo.means, ClassInfo.covariances, ClassInfo.priors] = vl_gmm(mbhRaws, words);
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
 
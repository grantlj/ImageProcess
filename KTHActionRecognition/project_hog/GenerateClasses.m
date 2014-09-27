%生成bag-of-words 单词
function [] = GenerateClasses()
  root=(GetPresentPath);
  path='hogRAW/';
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';

  
  
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'HOG.mat')>=1))
        filename=[path,name];                   %   组成文件名
        fileInfo=[fileInfo;filename];
     end
  end
  
  hogCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  disp('Loading hog-raw files...');
    
    total=0;
    for i=1:hogCount
      load(fileInfo{i});
     % disp(['Now handling:',num2str(i),'/',num2str(siftCount)]);
     
      for j=1:size(ret,2)
         sgFrame=ret{j};
       %  sgFrame=sgFrame(1);
         total=total+size(sgFrame,1)*size(sgFrame,2);
      end
    end
    disp(total);
    siftRaws=zeros(total,size(sgFrame,3));
  
  total=0;
  for i=1:hogCount
      load(fileInfo{i});
      disp(['Now handling:',num2str(i),'/',num2str(hogCount)]);
     
      for j=1:size(ret,2)
         sgFrame=ret{j};
         for k=1:size(sgFrame,1)
             for l=1:size(sgFrame,2)
                 total=total+1;
                 siftRaws(total,:)=sgFrame(k,l,:);
             end
         end
      end
      
  end
 
  
  %   X N*P的数据矩阵
%   K 表示将X划分为几类，为整数
%   Idx N*1的向量，存储的是每个点的聚类标号
%   C K*P的矩阵，存储的是K个聚类质心位置
%   sumD 1*K的和向量，存储的是类间所有点与该类质心点距离之和
%   D N*K的矩阵，存储的是每个点与所有质心的距离
   siftRaws=double(siftRaws);
   %siftRaws=siftRaws(1:round(size(siftRaws,1)*0.10));
   rowrank=randperm(size(siftRaws,1));
   siftRaws=siftRaws(rowrank,:);
   siftRaws=siftRaws(1:round(size(siftRaws,1)*0.03),:);
   
   for i=1:7
        words=10+(i-1)*5;
        disp(['K-means clusting...','Words:',num2str(words)]);
       [Idx,C]=kmeans(siftRaws,words,'emptyaction','drop','Replicates',3);
       classInfo.Idx=Idx;
       classInfo.C=C;
       %classInfo.sumD=D;classInfo.D=D;
       disp('Saving class info...');
       save([num2str(words),'_',classInfoPath],'classInfo');
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
 


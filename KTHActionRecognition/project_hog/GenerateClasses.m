%����bag-of-words ����
function [] = GenerateClasses()
  root=(GetPresentPath);
  path='hogRAW/';
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';

  
  
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'HOG.mat')>=1))
        filename=[path,name];                   %   ����ļ���
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
 
  
  %   X N*P�����ݾ���
%   K ��ʾ��X����Ϊ���࣬Ϊ����
%   Idx N*1���������洢����ÿ����ľ�����
%   C K*P�ľ��󣬴洢����K����������λ��
%   sumD 1*K�ĺ��������洢����������е���������ĵ����֮��
%   D N*K�ľ��󣬴洢����ÿ�������������ĵľ���
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
 


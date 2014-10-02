%����bag-of-words ����

function [] = GenerateClasses()
  root=(GetPresentPath);
  path='traRAW/';
  
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';
  
 
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'TRA.mat')>=1))
        filename=[path,name];  %   ����ļ���
        fileInfo=[fileInfo;filename];
     end
  end
  
  traCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  disp('Loading tra-raw files...');
  %ͳ�����������ĸ��������ڿ�������Raws.
    total=0;
    for i=1:traCount
      load(fileInfo{i});
     % disp(['Now handling:',num2str(i),'/',num2str(siftCount)]);
      total=total+size(ret,1);
    end
    
    disp(total);
    
    traRaws=zeros(total,size(ret,2));
    total=0;
     for i=1:traCount
      load(fileInfo{i});
      disp(['Now handling:',num2str(i),'/',num2str(traCount)]);
      for j=1:size(ret,1)
          total=total+1;
          traRaws(total,:)=ret(j,:);
      end
     end

  
%   X N*P�����ݾ���
%   K ��ʾ��X����Ϊ���࣬Ϊ����
%   Idx N*1���������洢����ÿ����ľ�����
%   C K*P�ľ��󣬴洢����K����������λ��
%   sumD 1*K�ĺ��������洢����������е���������ĵ����֮��
%   D N*K�ľ��󣬴洢����ÿ�������������ĵľ���


%    �˴�ע�ͽ����10%��Vector�����ɴʵ䣬������ԭ��˳��
   traRaws=double(traRaws);
   rowrank=randperm(size(traRaws,1));
   traRaws=traRaws(rowrank,:);
   traRaws=traRaws(1:round(size(traRaws,1)*0.1),:);
   
   for i=1:5
        words=10+(i-1)*5;
        disp(['K-means clusting...','Words:',num2str(words)]);
       [Idx,C]=kmeans(traRaws,words,'emptyaction','drop','Replicates',3);
       %classInfo.Idx=Idx;
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
 


%Fisher-Vector�汾
%����Vlfeat�⣬����GMMģ�Ͱ汾��words

function [] = GenerateClasses()
  vl_setup;
  root=(GetPresentPath);
  path='siftRAW/';
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='ClassInfo.mat';

  
  
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'SIFT.mat')>=1))
        filename=[path,name];                   %   ����ļ���
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
 


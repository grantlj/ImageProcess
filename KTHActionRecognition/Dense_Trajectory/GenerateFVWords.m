%Use fisher-vector and GMM model to generate Dense-MBH words.
function GenerateFVWords()
  vl_setup;
  root=(GetPresentPath);
  path='MBHRAW/';
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  %hufileInfo={};
  classInfoPath='FV_ClassInfo.mat';

  
  
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'MBH.mat')>=1))
        filename=[path,name];                   %   ����ļ���
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
  %���ѡ��10%����������gmm����
  
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
 
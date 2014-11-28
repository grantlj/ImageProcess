function []=GmmModelVerify()
  path='fvRAW\';
  root=(GetPresentPath);
  
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fvfileInfo={};
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'_FV.mat')>=1) )
     
        filename=[path,name];                   %   ����ļ���
        fvfileInfo=[fvfileInfo;filename];
       
     end
  end
  
  fvCount=size(fvfileInfo,1);
  t=cd(root);
  clc;
  load(fvfileInfo{1});
  dim=size(fvVal',2);
  fvs=zeros(fvCount,dim);
  for i=1:fvCount
    load(fvfileInfo{i});
    fvVal=fvVal';
    fvs(i,:)=fvVal(1,:);
  end
  
 %action count;
 actionCount=5;
 %scene count;
 sceneCount=4;
 [PX MODEL] = gmm(fvs, 20);    %first, we clustter by actions!
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
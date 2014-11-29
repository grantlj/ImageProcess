function []=GmmModelVerify()
  vl_setup;
  path='histRAW/';
  root=(GetPresentPath);
  
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  HISTfileInfo={};
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'_HIST.mat')>=1) )
     
        filename=[path,name];                   %   ����ļ���
        HISTfileInfo=[HISTfileInfo;filename];
       
     end
  end
  
  fvCount=size(HISTfileInfo,1);
  t=cd(root);
  clc;
  load(HISTfileInfo{1});
  dim=size(histVal,2);
  hists=zeros(fvCount,dim);
  for i=1:fvCount
    load(HISTfileInfo{i});
    %histVal=fvVal';
    hists(i,:)=histVal(1,:);
  end
  
 %action count;
 actionCount=5;
 %scene count;
 sceneCount=4;
 filename='actionOnly.mat';
 [means,cov,priors]=vl_gmm(hists', actionCount);    %first, we clustter by actions!
 save(filename,'means','cov','priors');
 
  filename='sceneOnly.mat';
 [means,cov,priors]=vl_gmm(hists', sceneCount);
  save(filename,'means','cov','priors');
  
 filename='scene_action_MIX.mat';
 [means,cov,priors]=vl_gmm(hists', actionCount*sceneCount);
  save(filename,'means','cov','priors');
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
function []=GmmModelVerify()
  vl_setup;
  path='histRAW/';
  root=(GetPresentPath);
  
  t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  HISTfileInfo={};
  for i= 3:n                               % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                  %  逐次取出文件名
     if ( (findstr(name,'_HIST.mat')>=1) )
     
        filename=[path,name];                   %   组成文件名
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
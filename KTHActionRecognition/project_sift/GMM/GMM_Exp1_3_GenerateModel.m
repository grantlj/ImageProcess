function []=GMM_Exp1_3_GenerateModel()
% Experiment 1_3:（SIFT的bag-of-words dim=18结果 GMM=15)
%   1. 每个动作训练15的GMM（使用vl_gmm)做，全场景测试，（每个动作训练集：40个(hist_trainSet) 随机选择，测试集：60个
% (hist_testSet）；
%   2. 判别方法：找最小分布所在的region对应的class
% 代码：project_sift\GMM
%============================================================================================================
% GMM_Exp1_GenerateModel:训练每种动作类别下的GMM。
  fileNameRoot='GMM_Exp1_3_GenerateModel_';
  vl_setup;
  path='hist_trainSet/';
  
  actionTypes={'boxing','handclapping','jogging','running','walking'};
  actionCount=size(actionTypes,2);
  root=(GetPresentPath);
 % disp(actionTypes{1});
  for action=1:actionCount
      t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
      allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
      [m,n] = size(allnames);
      HISTfileInfo={};
      for i= 3:n                               % 从3开始。前两个属于系统内部。
         name = allnames{1,i}                  %  逐次取出文件名
         if ( (findstr(name,'_HIST.mat')>=1) & (findstr(name,actionTypes{action})>=1) )
            filename=[path,name];                   %   组成文件名
            HISTfileInfo=[HISTfileInfo;filename];

         end
      end

      histCount=size(HISTfileInfo,1);
      t=cd(root);
      clc;
      load(HISTfileInfo{1});
      dim=size(histVal,2);
      hists=zeros(histCount,dim);
      for i=1:histCount
        load(HISTfileInfo{i});
        %histVal=fvVal';
        hists(i,:)=histVal(1,:);
      end
      
      clusterCount=15;               %each GMM has 4 sub-models.
      filename=['Models/',fileNameRoot,actionTypes{action},'.mat'];
      [means,cov,priors]=vl_gmm(hists',clusterCount);
      save(filename,'means','cov','priors');
%      %action count;
%      actionCount=5;
%      %scene count;
%      sceneCount=4;
%      filename='actionOnly.mat';
%      [means,cov,priors]=vl_gmm(hists', actionCount);    %first, we clustter by actions!
%      save(filename,'means','cov','priors');
% 
%       filename='sceneOnly.mat';
%      [means,cov,priors]=vl_gmm(hists', sceneCount);
%       save(filename,'means','cov','priors');
% 
%      filename='scene_action_MIX.mat';
%      [means,cov,priors]=vl_gmm(hists', actionCount*sceneCount);
%       save(filename,'means','cov','priors');
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
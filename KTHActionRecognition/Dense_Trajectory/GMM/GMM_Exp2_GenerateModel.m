function []=GMM_Exp2_GenerateModel()
% ��dense trajectory����
% Experiment 2(dense trajectory+fisher vector test gmm=8)
% . ÿ������ѵ��8��GMM��ʹ��vl_gmm)����ȫ�������ԣ���ÿ������ѵ������40��(hist_trainSet) ���ѡ�񣬲��Լ���60��(hist_testSet����
%   2. �б𷽷�������С�ֲ����ڵ�region��Ӧ��class
% ���룺DenseTrajectory\GMM
%============================================================================================================
% GMM_Exp2_MainTester:�����Գ���
  fileNameRoot='GMM_Exp2_GenerateModel_';
  vl_setup;
  path='fv_trainSet/';
  
  actionTypes={'boxing','handclapping','jogging','running','walking'};
  actionCount=size(actionTypes,2);
  root=(GetPresentPath);
 % disp(actionTypes{1});
  for action=1:actionCount
      t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
      allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
      [m,n] = size(allnames);
      HISTfileInfo={};
      for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
         name = allnames{1,i}                  %  ���ȡ���ļ���
         if ( (findstr(name,'_FV.mat')>=1) & (findstr(name,actionTypes{action})>=1) )
            filename=[path,name];                   %   ����ļ���
            HISTfileInfo=[HISTfileInfo;filename];

         end
      end

      histCount=size(HISTfileInfo,1);
      t=cd(root);
      clc;
      load(HISTfileInfo{1});
      dim=size(fvVal,2);
      hists=zeros(histCount,dim);
      for i=1:histCount
        load(HISTfileInfo{i});
        %histVal=fvVal';
        hists(i,:)=fvVal(1,:);
      end
      
      clusterCount=4;               %each GMM has 8 sub-models.
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
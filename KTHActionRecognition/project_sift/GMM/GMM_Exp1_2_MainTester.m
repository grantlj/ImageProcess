function GMM_Exp1_2_MainTester()
% Experiment 1-2:（SIFT的bag-of-words dim=18结果)
%  GMM数量：4个
%   1. 每个动作训练8的GMM（使用vl_gmm)做，全场景测试，（每个动作训练集：40个(hist_trainSet) 随机选择，测试集：60个
% (hist_testSet）；
%   2. 判别方法：找最小分布所在的region对应的class
% 代码：project_sift\GMM
%============================================================================================================
% GMM_Exp1_MainTester:主测试程序；


fileNameRoot='GMM_Exp1_2_GenerateModel_';
path='hist_testSet/';
actionTypes={'boxing','handclapping','jogging','running','walking'};
actionCount=size(actionTypes,2);
root=(GetPresentPath);
totalExp=10;
for expCount=1:totalExp                            %10次试验平均结果
        GMM_Exp1_2_GenerateModel();
       

        %load models.
        for action=1:actionCount
          models{action}=load(['Models/',fileNameRoot,actionTypes{action},'.mat']);
          results.accuracy{action,1}=actionTypes{action};
          results.accuracy{action,expCount+1}=0;
        end
        videoCount=0;

        %load actions one-by-one.
        for action=1:actionCount
           results.accuracy{action,totalExp+2}=0;
           t=cd(path);
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
              hists(i,:)=histVal(1,:);
            end


            for i=1:histCount
            mindisp=inf; flag=-1;
            videoCount=videoCount+1;
            %compare start.
              for classes=1:actionCount
                  for gmms=1:size(models{classes}.means,2)
                    v1=models{classes}.means(:,gmms)';
                    v2=hists(i,:);
                    dist=pdist([v1;v2]); %calculate distances!!
                    if (dist<mindisp)
                        mindisp=dist;
                        flag=classes;
                    end
                  end
              end

               %compare end; now we evaluate results. 
               results.log{videoCount,1}=HISTfileInfo{i};
               results.log{videoCount,expCount+1}=flag;

               if (flag==action)
                   results.accuracy{action,expCount+1}=results.accuracy{action,expCount+1}+1;
               end

            end
            %for this round's performance;
            results.accuracy{action,expCount+1}=results.accuracy{action,expCount+1}./histCount;
        end
end  %end of exp count;

results.accuracy{action+1,1}=0;
totalaccuracy=0;
 for action=1:actionCount   %get average performance;
   s=0;
   for i=2:expCount+1;
     s=s+results.accuracy{action,i};
   end
   results.accuracy{action,totalExp+2}=s./totalExp;
   totalaccuracy=totalaccuracy+results.accuracy{action,totalExp+2};
 end;
 results.accuracy{actionCount+1,1}=totalaccuracy./actionCount;
 save(['Results/',fileNameRoot,'Results.mat'],'results');
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
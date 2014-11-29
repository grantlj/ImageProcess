function GMM_Exp1_2_MainTester()
% Experiment 1-2:��SIFT��bag-of-words dim=18���)
%  GMM������4��
%   1. ÿ������ѵ��8��GMM��ʹ��vl_gmm)����ȫ�������ԣ���ÿ������ѵ������40��(hist_trainSet) ���ѡ�񣬲��Լ���60��
% (hist_testSet����
%   2. �б𷽷�������С�ֲ����ڵ�region��Ӧ��class
% ���룺project_sift\GMM
%============================================================================================================
% GMM_Exp1_MainTester:�����Գ���


fileNameRoot='GMM_Exp1_2_GenerateModel_';
path='hist_testSet/';
actionTypes={'boxing','handclapping','jogging','running','walking'};
actionCount=size(actionTypes,2);
root=(GetPresentPath);
totalExp=10;
for expCount=1:totalExp                            %10������ƽ�����
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
           allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
           [m,n] = size(allnames);
            HISTfileInfo={};
            for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
               name = allnames{1,i}                  %  ���ȡ���ļ���
               if ( (findstr(name,'_HIST.mat')>=1) & (findstr(name,actionTypes{action})>=1) )
                  filename=[path,name];                   %   ����ļ���
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
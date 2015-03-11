function [] = wi_dsift_cluster()
try
     addpath(genpath('VLFEATROOT'));
     vl_setup;
 catch
 end
 feature_set_path={'WI/chase/','WI/exchange_object/',...
              'WI/handshake/','WI/highfive/',...
              'WI/hug/','WI/hustle/',...
              'WI/kick/','WI/kiss/','WI/pat/'};                                     %corresponding feature saving path.
 m=size(feature_set_path,2);
 
 root=GetPresentPath();
 feat_to_cluster=[];
 for i=1:1:m
    now_feat_set=feature_set_path{i};
    t=cd(now_feat_set);
    clc;
    allnames=struct2cell(dir);
    [~,n] = size(allnames);
    cd(root);  
    
      for j=1:n
        name=allnames{1,j};
        ace=strfind(name,'-DSIFT-Feature.mat');
        if (~isempty(strfind(name,'-DSIFT-Feature.mat')))                     %traget file.
          disp(['Loading...',num2str(j),now_feat_set]);
          featname=[now_feat_set,name];                                      %feat file path.
          load(featname);
          sel=randperm(144144);
          sel=sel(1:50);
          tmpfeat=double(feat(:,sel));
          
          %normlization.
%           for k=1:50
%             maxVal=max(tmpfeat(:,k));
%             minVal=min(tmpfeat(:,k));
%             tmpfeat(:,k)=(tmpfeat(:,k)-minVal)./(maxVal-minVal);
%           end
          feat_to_cluster=[feat_to_cluster,tmpfeat];
        end
    
     end%end of j
    
 end
 
 disp('Doing clusting...');
 numcluster=256;
 [centers, assignments] = vl_kmeans(feat_to_cluster, numcluster);
 save('dsift_centers.mat','centers');
 
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


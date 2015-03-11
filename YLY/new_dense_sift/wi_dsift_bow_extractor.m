function wi_dsift_bow_extractor()

 try
     addpath(genpath('VLFEATROOT'));
     vl_setup;
 catch
 end
 
 load('dsift_centers.mat');
 kdtree = vl_kdtreebuild(centers);
 
 feature_set_path={'WI/chase/','WI/exchange_object/',...
              'WI/handshake/','WI/highfive/',...
              'WI/hug/','WI/hustle/',...
              'WI/kick/','WI/kiss/','WI/pat/'}; %corresponding feature saving path.
 bow_set_path={'WI_BOW/chase/','WI_BOW/exchange_object/',...
              'WI_BOW/handshake/','WI_BOW/highfive/',...
              'WI_BOW/hug/','WI_BOW/hustle/',...
              'WI_BOW/kick/','WI_BOW/kiss/','WI_BOW/pat/'};   
          
          
 m=size(feature_set_path,2);
 
 root=GetPresentPath();
 
  for i=m:-1:1
    
    
    now_feat_set=feature_set_path{i};
    now_bow_set=bow_set_path{i};
    
    t=cd(now_feat_set);
    clc;
    allnames=struct2cell(dir);
    [~,n] = size(allnames);
    cd(root);
    
    mkdir(now_bow_set);
    
    for j=1:n
      name=allnames{1,j};
      %ace=strfind(name,'.avi');
      if (~isempty(strfind(name,'-DSIFT-Feature.mat')))                      %traget file.
          featname=[now_feat_set,name];            %video file path.
          bowname=[now_bow_set,strrep(name,'-DSIFT-Feature.mat','-BoW-Feature.mat')];  %feture file path.
          extract_BOW_feature(featname,bowname,centers,kdtree);
      end
    
    end%end of j
    
    
 end% end of i
 
end

function []=extract_BOW_feature(featurename,bowname,centers,kdtree)
tic;
  disp(['Handling:',featurename]);
  if (exist(bowname,'file'))
      disp('Skippeddd...');
  else
  load(featurename);
  bow=zeros(1,size(centers,2));
  for i=1:size(feat,2)
     now_feat=double(feat(:,i));
     [index, distance] = vl_kdtreequery(kdtree, centers, now_feat);
     bow(1,index)=bow(1,index)+1;
  end
  maxVal=max(bow);minVal=min(bow);
  bow=(bow-minVal)./(maxVal-minVal);
  save(bowname,'bow');
  end
toc;
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
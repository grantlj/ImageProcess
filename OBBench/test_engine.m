function [] = test_engine(searchArg)
  addpath(genpath('libsvm-3.18/'));
  try
      make
  catch
      disp('Error compiling libsvm...');
      pause;
  end
  if (nargin<1)
      searchArg=0;  %searchArg=0 means using default args train svm.
  else
     if (searchArg~=2), searchArg=1;end 
     %arg=1: trying to load bestarg file to svm train, if failed then
     %search for best c,g.
     %arg=2: obliging to search best c g for svm again.
  end
  datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'...
            'dataset/brush_hair/','dataset/catch/','dataset/clap/','dataset/climb_stairs/'...
            'dataset/golf/','dataset/jump/','dataset/kick_ball/','dataset/pour/','dataset/pullup/'...
            'dataset/push/','dataset/shoot_ball/','dataset/shoot_bow/','dataset/shoot_gun/','dataset/sit/'...
            'dataset/stand/','dataset/swing_baseball/'}; %search path;
  keyword='-Feature.mat'; %feature file key word.
  train_ratio=0.7;         %the radio of train set over all data. 
  svmmodel_path='SVMModel.mat'; %svm model file saving path.
  svmarg_path='SVMArgs.mat';    %svm arg file saving path.
  max_total_clips=100;          %the maximum number of train+test in each set.
  
  test_set=[];train_set=[]; train_label=[];test_label=[];
  root=(GetPresentPath);
  
  
  datalist_featureCount=zeros(1,size(datapath,2));
  datalist_train_num=zeros(1,size(datapath,2));
  
  for datacount=1:size(datapath,2)
  
     db=datapath{datacount};
     t=cd(db);
     clc;
     allnames = struct2cell(dir);            
     [m,n] = size(allnames);
     featureInfo={};
     for i= 1:n                              
        name = allnames{1,i}                 
          if ( ~(isempty(findstr(name,keyword))) && (strncmp(name,'LAG-',4)~=1))
             featurename=[db,name];                 
             featureInfo=[featureInfo;featurename];
        end
     end
     
     t=cd(root);
     clc;
     
     featureCount=size(featureInfo,1);
     train_num=randperm(featureCount,round(featureCount*train_ratio)); %generate trainset orders according to ratio.
     

     
     strain=0; stest=0;
     for i=1:featureCount
      try
           feat=extract_feature_fromfile(featureInfo{i});
           if (any(train_num==i)==1)   % i-th feature belongs to train_set.
             train_set=[train_set;feat];
             train_label=[train_label;datacount];
             strain=strain+1;
           else                       %other order num, belongs to test_set.
             test_set=[test_set;feat];
             test_label=[test_label;datacount];
             stest=stest+1;
           end
           
       catch
           disp(['Error reading file:',featureInfo{i}]);
           datalist_featureCount(1,datacount)=datalist_featureCount(1,datacount)-1;
           if (any(train_num==i)==1);datalist_train_num(1,datacount)=datalist_train_num(1,datacount)-1;end  
           
          % pause;
      end
      
       if ((strain+stest>=max_total_clips) && (strain>=max_total_clips*train_ratio) && (stest>=max_total_clips*(1-train_ratio)))
           break;
       end
     end
     
     datalist_featureCount(1,datacount)=strain+stest;
     datalist_train_num(1,datacount)=strain;
       
  end %datacount;
  
  clc;
  disp('Feature info:');
  
  for datacount=1:size(datapath,2)
     disp([datapath(1,datacount),'          Total=',num2str(datalist_featureCount(1,datacount)),'        Train=',num2str(datalist_train_num(1,datacount))]);
     
  end
  pause;
  clc;
  
    if ((~exist(svmarg_path,'file') && (searchArg~=0)) || (searchArg==2))   %file not exist and not in defualt mode or mandatory search again.
        disp('Searching for best svm args...');
        svmarg=SVMcgForClass(train_label,train_set,-8,8,-8,8,size(train_label,1),1,1,6);
        clc;
        disp(['bestCVaccuracy=',num2str(bestCVaccuracy),'   bestc=',num2str(bestc),'    bestg=',num2str(bestg)]);
        disp(['Saving svmargs...']);
        save(svmarg_path,'svmarg');
    end;
   
    if (searchArg~=0)  %not default mode, we must load svmarg file.
        disp('Loading svm svmarg...');
        load(svmarg_path);
       
    else
        svmarg.bestc=1e200;  %default, the args are as same as that in feifei's raw code.
        svmarg.bestg=length(unique(test_label));
    end
    
    %Training and test accuracy.
    disp('Training svm...');
    model=svmtrain(train_label,train_set,['-t 0 -c ',num2str(svmarg.bestc),' -g ',num2str(svmarg.bestg)]);  %temporary only.
    save(svmmodel_path,'model');
    disp('Running test...');    
    [~, accur, ~]=svmpredict(test_label,test_set,model);               
    disp(['Accuracy=',num2str(accur(1))]);      
   
        
end

function [featureVector] = extract_feature_fromfile(fileinfo)
  %For OBBench use only. extract feature from specific file.
  A=load(fileinfo);
  featureVector=A.feature;
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
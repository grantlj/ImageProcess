%Generate latent svm model.(1v1 svm)
%Comparing test: 50 feature dim randomly selected. classical libsvm: 33.3%
function [] = lsvm_generator_1v1(splits_num)
addpath(genpath('libsvm-3.18/'));
  try
      make
  catch
      disp('Error compiling libsvm...');
      pause;
  end
  
   if (~exist('splits_num','var'))
     splits_num=1;
   end
  
   datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'...
                 'dataset/brush_hair/','dataset/catch/','dataset/clap/','dataset/climb_stairs/'};
             
% datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'};
 %datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/wave/'};
 splits_path='dataset/testTrainMulti_7030_splits/';
% datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'...
%             'dataset/brush_hair/','dataset/catch/','dataset/clap/','dataset/climb_stairs/'...
%             'dataset/golf/','dataset/jump/','dataset/kick_ball/','dataset/pour/','dataset/pullup/'...
%             'dataset/push/','dataset/shoot_ball/','dataset/shoot_bow/','dataset/shoot_gun/','dataset/sit/'...
%             'dataset/stand/','dataset/swing_baseball/'};
 keyword='-Feature.mat'; %feature file key word.
 %train_ratio=0.7;         %the radio of train set over all data. 
 global train_w_b_ratio;
 
 train_w_b_ratio=0.5;     %we specify different train_data for w b and theta.
% max_total_clips=100;          %the maximum number of train+test in each set.
 
 test_set={};train_set={}; %train_label=[];test_label=[];
 
  root=(GetPresentPath);
 
 datalist_featureCount=zeros(1,size(datapath,2));
 datalist_train_num=zeros(1,size(datapath,2));
 
 row_dim=44604;
  rand_row=randperm(row_dim);
% rand_row=1:252 %random selected some feature dims. 
  rand_row=rand_row(1:44604);
save('1v1_lsvm_rand_row.mat','rand_row');  %save it, for later use.
 
 for datacount=1:size(datapath,2)
     db=datapath{datacount};
     naked_class_name=get_naked_class_name(datapath{datacount});
     splits_file=[splits_path,naked_class_name,'_test_split',num2str(splits_num),'.txt'];
     fid=fopen(splits_file,'r');
     
     strain=0; stest=0;
     trains={};tests={}; train_label=[];test_label=[];
     
     while (~feof(fid))
        tmpstr=fgets(fid);
        split_tmpstr=regexp(tmpstr,' ', 'split');
        featurename=[split_tmpstr{1},keyword];tag=str2num(split_tmpstr{2});
        
       try
           
        if (tag==1) %train set
          feat=extract_feature_fromfile(db,featurename);
          feat=feat(:,rand_row);
          strain=strain+1;
          trains{strain}=feat;
          train_label=[train_label;datacount];
          
        elseif (tag==2) %test set
          feat=extract_feature_fromfile(db,featurename);
          feat=feat(:,rand_row);
          stest=stest+1;
          tests{stest}=feat;
          test_label=[test_label;datacount];
        end
        
       catch
             disp(['Error reading file:',featurename]); 
       end
        
    end   %end of while 
    
      
      train_set{datacount}.trains=trains; train_set{datacount}.train_label=train_label;
      
      test_set{datacount}.tests=tests; test_set{datacount}.test_label=test_label;
      
      clear trains;
      clear tests;
     
     datalist_featureCount(1,datacount)=strain+stest;
     datalist_train_num(1,datacount)=strain;
       
  end %datacount;
  
  save('1v1_lsvm_test_set.mat','test_set','-v7.3');   %save the test_set, for the convenience of test_engine.
  
  %data initializing finished.
  
  
  %======================================================================
  %=================THE ALTERNATIVE SEARCH METHOD========================
  %======================================================================
  

  T=30;   %the normalized frame count after lagrange.
  %thetaCount=size(train_set{1}.trains{1},2);  %how many theta vector. 40000+
  
  %thetaMat=zeros(thetaCount,T);     %each row a single weight for one feature dim, in one svm model. 
  global initWeight;
 % for i=1:thetaCount
    initWeight=1/T.*ones(1,T);     %initial value means "Mean-Pooling"
   % thetaMat(i,:)=initWeight;
  %end
  

  
  %======================================================================
  %=======================RUN COMPARE TEST===============================
  %======================================================================
  %using classical libsvm model to conduct comparing test.

  
  
 % modelCount=size(datapath,2);     %number of 1-n svm.
 
 global chosek;
 chosek=nchoosek([1:size(datapath,2)],2);
 modelCount=size(chosek,1);
 
 models={};
  
  for i=1:modelCount               %initialize thetaMat,w,b for each model.
     model.thetaMat=initWeight;
     model.w=[];model.b=[];
     model.comment=chosek(i,:);
     models{i}=model;
  end
  %run_compared_test(train_set,test_set,models);
%load('workspace.mat');

  for itecount=1:100   %begin iteration.
      
      for i=1:modelCount
         %Step 1: Update w and b in 1 v 1 svm using default theta.
        models{i}=lsvm_update_w_b(train_set,models{i},chosek(i,:));
      end
      
      if (itecount==1)
          save('lsvm_model/1v1_Models_After_ITE_0.mat','models');  %save default mean-pooling strategy for comparing test.
      end
     % else
      %    
     % end
      
      for i=1:modelCount
        %Step 2: Update theata using w,b in step 1.
        models{i}=lsvm_update_theta(train_set,models{i},chosek(i,:));
      end
      save(['lsvm_model/1v1_Models_After_ITE_',num2str(itecount),'.mat'],'models');
      
   end
  
     
end

%Run comparing test by 1vN svm. thetaMat at present is the Mean-Pooling 
%strategy.
% function []=run_compared_test(train_set,test_set,models)
% 
%     comp_train_feat=[];comp_train_label=[];
%     comp_test_feat=[];comp_test_label=[];
%     
%     %initialize labels.
%     for datacount=1:size(train_set,2)
%        comp_train_label=[comp_train_label;train_set{datacount}.train_label];
%        comp_test_label=[comp_test_label;test_set{datacount}.test_label];
%     end
%     
%     %initialize train set.
%     for datacount=1:size(train_set,2)
%       trains=train_set{datacount}.trains;
%       featureCount=size(trains,2);
%       
%       for i=1:featureCount
%           feat=trains{i};     %raw feat for each video.
%           if (isempty(feat))
%               continue;
%           end
%       
%           vec=[]; 
%           for k=1:size(feat,2)    %obtain the vec.
%               vec=[vec,thetaMat(k,:)*feat(:,k)];
%           end
%           comp_train_feat=[comp_train_feat;vec];
%       end
%     end
%     
%      %initialize test set.
%     for datacount=1:size(test_set,2)
%       tests=test_set{datacount}.tests;
%       featureCount=size(tests,2);
%       
%       for i=1:featureCount
%           feat=tests{i};     %raw feat for each video.
%           if (isempty(feat))
%               continue;
%           end
%       
%           vec=[]; 
%           for k=1:size(feat,2)    %obtain the vec.
%               vec=[vec,thetaMat(k,:)*feat(:,k)];
%           end
%           comp_test_feat=[comp_test_feat;vec];
%       end
%     end
%     
%    % svmarg.bestc=1e200;  %default, the args are as same as that in feifei's raw code.
%     svmarg.bestg=length(unique(comp_train_label));
%     comp_model=svmtrain(comp_train_label,comp_train_feat,['-t 0  -g ',num2str(svmarg.bestg)]);  %temporary only.
% 
%     % save(svmmodel_path,'model');
%     disp('Running test...');    
%     [~, accur, ~]=svmpredict(comp_test_label,comp_test_feat,comp_model);               
%     disp(['Accuracy=',num2str(accur(1))]);      
% 
%     disp(['Comparing test finished!!!!! Press any key to continue lsvm_generator']);
%     pause;
% 
% end

%constraint function of theta.
function [c ceq]=theta_con(thetaMatVec)
 %  disp('in theta con');
   thetaMat=thetaMatVec';
   
  for i=1:size(thetaMat,1)
    ceq(i)=sum(thetaMat(i,:),2)-1;   %sum of each row must be 1;
%     for j=1:size(thetaMat,2)
%          c((i-1)*size(thetaMat,1)+j)=-thetaMat(i,j);  %each theta must be larger than 1
%      end
  end
  c=[];
% ceq=[];
end

%optimization funciton of theta.
function f=theta_opt(thetaMatVec)
 % disp('in theta opt');
  thetaMat=thetaMatVec';
 % f=-rank(thetaMat)-cos(rank(thetaMat));
  
  global train_set_global; global train_label;
  global tag2;
  
  global train_w_b_ratio;
  
  train_feat=[];
  f=0;
  for i=1:size(train_set_global,2)
     for j=floor(size(train_set_global{i}.trains,2)*train_w_b_ratio)+1:size(train_set_global{i}.trains,2)
         
         if (i==tag2(1,1) || i==tag2(1,2))
         feat_new=train_set_global{i}.trains{j};   %a single video's mat.
        
         if(isempty(feat_new)) continue; end;
         vec=[];                            % a single video's final result.
%          for k=1:size(feat_new,2)
%              vec=[vec,thetaMat(k,:)*feat_new(:,k)];
%          end
         vec=thetaMat*feat_new;
         train_feat=[train_feat;vec];
         
%          if (i==tag)
%              train_label_native=[train_label_native;1];   %belongs to present 1-n svm's positive examples.
%          else
%              train_label_native=[train_label_native;-1];  %otherwise;
%          end
         end
     end  %end of a single action class.
         
  end
  
  global w_global;
  global b_global;
%  global svmmodel_global;
  
  f=0;
  for i=1:size(train_feat,1)
    tmp=(1-train_label(i)*(w_global'*train_feat(i,:)'+b_global));
    % [predicted_label,accuracy,decision_values]=svmpredict(1,train_feat(i,:),svmmodel_global);
    % tmp=1-train_label(i)*decision_values;
     if (tmp<0), tmp=0;end;
     f=f+tmp;
  end
  
  clear train_feat;
end



% The first step in alternative search: giving w and b in 
% each model, find the best theta.
function [model]=lsvm_update_theta(train_set,model,tag)

  global train_set_global; global train_label;
  train_set_global=train_set;
  train_label=[];
  
  global train_w_b_ratio;
  
   global w_global;
   w_global=model.w;
   global b_global;
   b_global=model.b;
  
   global svmmodel_global;
   svmmodel_global=model.svmmodel;
   
   global tag2;
   tag2=tag;
  %spos=size(train_set{tag}.trains,2);
  
  for i=1:size(train_set,2)
    % snega=0;
     for j=floor(size(train_set{i}.trains,2)*train_w_b_ratio)+1:size(train_set{i}.trains,2)
         feat_new=train_set{i}.trains{j};   %a single video's mat.
         if(isempty(feat_new)) continue; end;
         if (i==tag(1,1))
             train_label=[train_label;1];   %belongs to present 1-n svm's positive examples.
         elseif (i==tag(1,2))
             train_label=[train_label;-1];  %otherwise;
             
         end
     end  %end of a single action class.
  end
  
 % options = optimset('GradObj', 'on', 'MaxIter', 1000);
 %  options=optimoptions(@fmincon,'Algorithm','sqp','Display','iter-detailed');
  opts = optimoptions(@fmincon,'MaxFunEvals',50000);
  %[ansMat,fval]=fmincon(@theta_opt,zeros(size(model.thetaMat(:)')));%,[],[])   % ,[],[],[],[],'theta_con',opts);
  global initWeight;
  [ansMat,fval, exitflag]=fmincon(@theta_opt, ...                                                             %goal function.                                                    initial value.
                                  initWeight',...
                                  [],[],                    ...                                               %linear inequility. A,b
                                  [],[],                          ...                                         %linear equiity. Aeq,beq
                                  zeros(1,size(model.thetaMat(:)',1)*size(model.thetaMat(:)',2)), ...         %lower bound.
                                  [],...                                                                      %upper bound.
                                  @theta_con,opts);                                                           %constraint function.
                                                                                                   
  %                                 
  model.thetaMat=ansMat';
  model.exitflag=exitflag;
  model.fval=fval+1/2*model.w'*model.w;
  
  %normalization operation.
   s=sum(model.thetaMat,2);
  for i=1:size(model.thetaMat,1)
     model.thetaMat(i,:)=model.thetaMat(i,:)./s(i);
  end
end
 
% The first step in alternative search: extract w and b giving
% thetaMat.(for each 1-n SVM.
function [model]=lsvm_update_w_b(train_set,model,tag)
  thetaMat=model.thetaMat;
  train_feat=[]; train_label=[];
  global train_w_b_ratio;

  for i=1:size(train_set,2)
  
     for j=1:floor(size(train_set{i}.trains,2)*train_w_b_ratio)   %specify w b's data.
         feat_new=train_set{i}.trains{j};   %a single video's mat.
         if(isempty(feat_new)) 
             continue; 
         end;
         vec=[];                            % a single video's final result.
%          for k=1:size(feat_new,2)
%              vec=[vec,thetaMat(k,:)*feat_new(:,k)];
%          end
         vec=thetaMat*feat_new;
         if (i==tag(1,1))
             train_label=[train_label;1];   %belongs to present 1-n svm's positive examples.
             train_feat=[train_feat;vec];
             %spos=spos+1;
         elseif (i==tag(1,2))
             train_label=[train_label;-1];  %otherwise;
            
             train_feat=[train_feat;vec];
             
         end
     end  %end of a single action class.
         
  end
    
    %doing linear svm.
    svmarg.bestc=1e200;  %default, the args are as same as that in feifei's raw code.
    svmarg.bestg=length(unique(train_label));
    svmmodel=svmtrain(train_label,train_feat,['-t 0 -c ',num2str(svmarg.bestc),' -g ',num2str(svmarg.bestg)]); 
    %svmmodel=svmtrain(train_label,train_feat,['-t 0 -g ',num2str(svmarg.bestg)]);
    %extract w and b from svmmodel.
    try
    model.w=svmmodel.SVs'*svmmodel.sv_coef;
    model.b=-svmmodel.rho;%
    model.svmmodel=svmmodel;
    clear svmmodel;
    clear train_feat;
    clear train_label;
    catch
       pause;
    end
    
    
end
 
 function [featureVector] = extract_feature_fromfile(db,fileinfo)
  %For OBBench use only. extract feature from specific file.
  %In this lsvm case, we need to perform lagrange-method at first.
   %A=load(fileinfo);
   %featureVector=A.feature;
  if (~exist([db,'LAG-',fileinfo],'file'))
      
     %does not exist lagrange file, load raw data.
     A=load([db,fileinfo]);
     disp(['Doing lagrange on:',db,fileinfo]);
     feat_new=lagrange_opt(A.feat_raw);     %perform lagrange.
     save([db,'LAG-',fileinfo],'feat_new');
  else
      load([db,'LAG-',fileinfo]);
  end
  featureVector=feat_new;
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


function [naked_class_name]=get_naked_class_name(naked_class_name)
 dash_pos=findstr(naked_class_name,'/');
 naked_class_name=naked_class_name(dash_pos(1,1)+1:dash_pos(1,2)-1);
end

%     t=cd(db);
%      clc;
%      allnames = struct2cell(dir);            
%      [m,n] = size(allnames);
%      featureInfo={};
%      for i= 1:n                              
%         name = allnames{1,i}                 
%         if ( ~(isempty(findstr(name,keyword))) && (strncmp(name,'LAG-',4)~=1))
%              featurename=[name];                 
%              featureInfo=[featureInfo;featurename];
%         end
%      end
%      
%      t=cd(root);
%      clc;
%      
%      featureCount=size(featureInfo,1);
%      train_num=randperm(featureCount,round(featureCount*train_ratio)); %generate trainset orders according to ratio.
%      
%      datalist_featureCount(1,datacount)=featureCount;
%      datalist_train_num(1,datacount)=size(train_num,2);
%      
%       strain=0; stest=0;
%       trains={};tests={}; train_label=[];test_label=[];
%       
%       for i=1:featureCount
%       try
%            feat=extract_feature_fromfile(db,featureInfo{i});
%            feat=feat(:,rand_row);
%            
%            if (any(train_num==i)==1)   % i-th feature belongs to train_set.
%              strain=strain+1;
%              trains{strain}=feat;
%              train_label=[train_label;datacount];
%               
%            else                       %other order num, belongs to test_set.
%              stest=stest+1;
%              tests{stest}=feat;
%              test_label=[test_label;datacount];
%               
%            end
%        catch
%            disp(['Error reading file:',featureInfo{i}]);
%            datalist_featureCount(1,datacount)=datalist_featureCount(1,datacount)-1;
%            if (any(train_num==i)==1);datalist_train_num(1,datacount)=datalist_train_num(1,datacount)-1;end  
%            
%           % pause;
%       end
%           if ((strain+stest>=max_total_clips) && (strain>=max_total_clips*train_ratio) && (stest>=max_total_clips*(1-train_ratio)))
%            break;
%        end
%      end
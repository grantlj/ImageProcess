%Generate latent svm model.(1vN svm)
%For TRECVID MED 2011 dataset.
function [] = lsvm_generator(test_object)
addpath(genpath('libsvm-3.18/'));
try
    make
catch
    disp('Error compiling libsvm...');
    pause;
end

global train_w_b_ratio;
train_w_b_ratio=0.5;
root=(GetPresentPath);
[train_set,test_set]=data_initialize(root,test_object);
cd(root);
save([test_object,'_test_set.mat'],'test_set','-v7.3');   %save the test_set, for the convenience of test_engine.
clear test_set;

%data initializing finished.


%======================================================================
%=================THE ALTERNATIVE SEARCH METHOD========================
%======================================================================


T=20;   %the normalized frame count after lagrange.
global initWeight;
initWeight=1/T.*ones(1,T);     %initial value means "Mean-Pooling"

model.thetaMat=initWeight;
model.w=[];model.b=[];
model.comment=test_object;

for itecount=1:100   %begin iteration.
    %Step 1: Update w and b in 1 v 1 svm using default theta.
    model=lsvm_update_w_b(train_set,model);
    if (itecount==1)
        save(['lsvm_model/',test_object,'_1vN_Models_After_ITE_0.mat'],'model');  %save default mean-pooling strategy for comparing test.
    end
    %Step 2: Update theata using w,b in step 1.
    model=lsvm_update_theta(train_set,model);
    save(['lsvm_model/',test_object,'_1vN_Models_After_ITE_',num2str(itecount),'.mat'],'model');
end


end

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


global train_w_b_ratio;

train_feat=[];
f=0;
for i=1:size(train_set_global,2)
    for j=1:size(train_set_global{i}.trains,2)
        
        if (i==1 || i==2)
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
    if (tmp<0), tmp=0;end;
    f=f+tmp;
end

clear train_feat;
end



% The first step in alternative search: giving w and b in
% each model, find the best theta.
function [model]=lsvm_update_theta(train_set,model)

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

%spos=size(train_set{tag}.trains,2);

for i=1:size(train_set,2)
    % snega=0;
  %  for j=floor(size(train_set{i}.trains,2)*train_w_b_ratio)+1:size(train_set{i}.trains,2)
   for j=1:size(train_set{i}.trains,2)   %cancel the w_b validation strategy.
        feat_new=train_set{i}.trains{j};   %a single video's mat.
        if(isempty(feat_new)) continue; end;
        if (i==1)
            train_label=[train_label;1];   %belongs to present 1-n svm's positive examples.
        elseif (i==2)
            train_label=[train_label;-1];  %otherwise;
            
        end
    end  %end of a single action class.
end

% options = optimset('GradObj', 'on', 'MaxIter', 1000);
%  options=optimoptions(@fmincon,'Algorithm','sqp','Display','iter-detailed');
opts = optimoptions(@fmincon,'MaxFunEvals',50000);
%[ansMat,fval]=fmincon(@theta_opt,zeros(size(model.thetaMat(:)')));%,[],[])   % ,[],[],[],[],'theta_con',opts);
global initWeight;

initWeight=rand(1,size(initWeight));               %random strategy.
initWeight=initWeight./sum(initWeight);

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

function [model]=lsvm_update_w_b(train_set,model)
thetaMat=model.thetaMat;
train_feat=[]; train_label=[];
global train_w_b_ratio;

for i=1:size(train_set,2)
    
  %  for j=1:floor(size(train_set{i}.trains,2)*train_w_b_ratio)   %specify w b's data.
     for j=1:size(train_set{i}.trains,2)   %cancel the w_b validation strategy.
        feat_new=train_set{i}.trains{j};   %a single video's mat.
        if(isempty(feat_new))
            continue;
        end;
        vec=[];                            % a single video's final result.
        %          for k=1:size(feat_new,2)
        %              vec=[vec,thetaMat(k,:)*feat_new(:,k)];
        %          end
        vec=thetaMat*feat_new;
        if (i==1)
            train_label=[train_label;1];   %belongs to present 1-n svm's positive examples.
            train_feat=[train_feat;vec];
            %spos=spos+1;
        elseif (i==2)
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
load([db,fileinfo]);
featureVector=feat_lag;
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

%generate destine paths.
function [datapath]=load_datapath(root_path,test_object,root)
cd(root_path);
allnames=struct2cell(dir);
n=size(allnames,2);
datapath={};
pos_path=[root_path,test_object,'/'];
datapath{1}=pos_path;         %save pos path as datapath{1}, others in 2,3,4...
total=1;

for i=1:n
    name=allnames{1,i};
    if (strcmp(name,'.') || strcmp(name,'..'))
        continue;
    end
    
    if (strcmp(name,test_object))  %training postive examples.
        continue;
    else                    %training negative examples.
        total=total+1;
        datapath{total}=[root_path,name,'/'];
    end
    
    
end
cd(root);
clc;
end

function [train_set,test_set]=data_initialize(root,test_object)
nega_pos_ratio=5;          %in train data, the negtaive example should be nega_pos_ratio numbers of pos example.
keyword='-Feature.mat';
dev_path='dataset_MED/train/';                               %train sets root path;
evl_path='dataset_MED/test/';
train_datapath=load_datapath(dev_path,test_object,root);
test_datapath=[evl_path,test_object,'/'];
%test sets root path;
train_pos_path=[dev_path,test_object,'/'];
train_set={}; test_set={};
train_set{1}.trains={}; train_set{1}.label=[];
train_set{2}.trains={}; train_set{2}.label=[];
pos_strain=0; nega_strain=0;
test_set{1}.tests={};
test_set{1}.label=[];

train_pos_total=0;
%load train data and train label.
for datacount=1:size(train_datapath,2)
    db=train_datapath{datacount};
    cd(db);
    clc;
    allnames = struct2cell(dir);
    [m,n] = size(allnames);
    featureInfo={};
    for i= 1:n
        name = allnames{1,i};
        if ( ~(isempty(strfind(name,keyword))))
            featurename=[name];
            featureInfo=[featureInfo;featurename];
        end
    end
    
    t=cd(root);
    clc;
    
    featureCount=size(featureInfo,1);
    featureInfo=featureInfo(randperm(featureCount));                          %get randomed.
    
    train_nega_total=0;
    for i=1:featureCount
        
        if (datacount==1)                                                     %is pos train example, load all;
            try
                feat=extract_feature_fromfile(db,featureInfo{i});
                pos_strain=pos_strain+1;
                train_set{1}.trains{pos_strain}=feat;
                train_set{1}.label=[train_set{1}.label;1];
                train_pos_total=train_pos_total+1;
            catch
                disp(['Feature file damaged:   ',db,featureInfo{i}]);
            end
        elseif (train_nega_total<(train_pos_total*nega_pos_ratio/(size(train_datapath,2)-1)))    %is negative train example, load as ratio.
            try
                feat=extract_feature_fromfile(db,featureInfo{i});
                nega_strain=nega_strain+1;
                train_set{2}.trains{nega_strain}=feat;
                train_set{2}.label=[train_set{2}.label;-1];
                train_nega_total=train_nega_total+1;
            catch
                disp(['Feature file damaged:   ',db,featureInfo{i}]);
            end
        end
    end
end

%train_set{2}.trains=train_set{2}.trains{randperm(size(train_set{2}.trains,2))};
cd(root);


test_datapath=load_datapath(evl_path,test_object,root);
cd(root);


stest=0;
for datacount=1:size(test_datapath,2)
    
    %load test data and test label.
    cd(test_datapath{datacount});
    clc;
    allnames = struct2cell(dir);
    [m,n] = size(allnames);
    featureInfo={};
    for i= 1:n
        name = allnames{1,i};
        if ( ~(isempty(strfind(name,keyword))))
            featurename=[name];
            featureInfo=[featureInfo;featurename];
        end
    end
    
    t=cd(root);
    clc;
    
    featureCount=size(featureInfo,1);
    featureInfo=featureInfo(randperm(featureCount));
    
    for i=1:featureCount
        try
        feat=extract_feature_fromfile(test_datapath{datacount},featureInfo{i});
        %feat=extract_feat_fromfile(test_datapath,featureInfo{i});
        stest=stest+1;
        test_set{1}.tests{stest}=feat;
        if (datacount==1); tag=1; else tag=-1;end
        test_set{1}.label=[test_set{1}.label;tag];
        catch
        disp(['Feature file damaged:   ',test_datapath{datacount},featureInfo{i}]);
        end
    end
    cd(root);
end
end

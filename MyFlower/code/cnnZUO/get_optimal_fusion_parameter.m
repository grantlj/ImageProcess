function [thetaVec] = get_optimal_fusion_parameter(svmmodel_1,svmmodel_2,train_label,train_feat_1,train_feat_2)


%n_class=max(train_label);feat_dim=size(train_feat_1,2)+size(train_feat_2,2);

%svmmodels_1=generate_individual_svmmodels(n_class,svmmodel_1);
%svmmodels_2=generate_individual_svmmodels(n_class,svmmodel_2);

load('get_fusion_parameter_temporal.mat');
thetaVec=[];
total=0;

global now_train_label;global now_train_feat_1;global now_train_feat_2;
global w1_global; global w2_global;
global b1_global; global b2_global;
for i=1:n_class-1
    for j=i+1:n_class
      total=total+1;
      
      disp(['Conduct optimization on:',num2str(i),'-',num2str(j),' model.']);
      %prepare the data for present optimization fusion.
      
      now_train_index=find(train_label==i);
      now_train_index=[now_train_index;find(train_label==j)];
      now_train_label=train_label(now_train_index,:);
      now_train_label(now_train_label==i)=1;now_train_label(now_train_label==j)=-1;
      now_train_feat_1=train_feat_1(now_train_index,:);
      now_train_feat_2=train_feat_2(now_train_index,:);
      
      w1_global=svmmodels_1{total}.w; b1_global=svmmodels_1{total}.b;
      w2_global=svmmodels_2{total}.w; b2_global=svmmodels_2{total}.b;
      
      theta=rand(1,feat_dim+1);  %initial value. the last dim is bias term.
      [theta,fval,exitflag]=fmincon(@theta_opt,theta,[],[],[],[],0,1);
      
      thetaVec=[thetaVec;theta];
      disp(['Exit flag=',num2str(exitflag)]);
    end
end

end

%%
%Optimization callback function.
function f=theta_opt(theta)
  global w1_global;global b1_global;
  global w2_global;global b2_global;
  global now_train_label;
  global now_train_feat_1;
  global now_train_feat_2;
  
  now_sum=0;
  for i=1:size(now_train_label,1)
    y=now_train_label(i);
    
    pooling_parameter=1/(1+exp(-(theta(1,1:end-1)*[now_train_feat_1(i,:),now_train_feat_2(i,:)]'+theta(1,end))));
    
%     tmp=1-pooling_parameter*y*(w1_global'*now_train_feat_1(i,:)'+b1_global)-(1-pooling_parameter)*y*(w2_global'*now_train_feat_2(i,:)'+b2_global);
%     if (tmp>0) 
%         now_sum=now_sum+tmp;
%     end

    pi_x=1/(1+exp(-(pooling_parameter*(w1_global'*now_train_feat_1(i,:)'+b1_global)+(1-pooling_parameter)*(w2_global'*now_train_feat_2(i,:)'+b2_global))));
    now_sum=now_sum+y*log(pi_x)+(1-y)*log(1-pi_x);
  end
  
  f=now_sum;
end
%%
%get individual svm model.
function [svmmodels]=generate_individual_svmmodels(n_class,svmmodel_1)
svmmodels={};
total=0;
for i=1:n_class-1
   for j=i+1:n_class
      total=total+1;
      [st_i,end_i]=get_index_from_nsv(svmmodel_1.nSV,i);
      [st_j,end_j]=get_index_from_nsv(svmmodel_1.nSV,j);
      
      %get coefficients.
      coef=[svmmodel_1.sv_coef(st_i:end_i,j-1);svmmodel_1.sv_coef(st_j:end_j,i)];
      %get support vectors.
      SVs=[svmmodel_1.SVs(st_i:end_i,:);svmmodel_1.SVs(st_j:end_j,:)];
      
      w=SVs'*coef;
      b=-svmmodel_1.rho(total);
      
      svmmodels{total}.w=w;
      svmmodels{total}.b=b;
      svmmodels{total}.comments=[num2str(i),'-',num2str(j)];
   end
end
end

%%
%get the position of support vector for each class.
function [stx,endx]=get_index_from_nsv(nsv,class_num)
  stx=0;
  for i=1:class_num-1
      stx=stx+nsv(i);
  end
  stx=stx+1;
  endx=stx+nsv(class_num)-1;
end


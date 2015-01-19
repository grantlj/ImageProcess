function []=run_lsvm_test_engine(test_object)

   % clear all;
    clc;
    acc=[];

    t=dir('lsvm_model/');
    modelcount=size(t,1)-3;

    % load('lsvm_rand_row.mat');    %load rand row info.
     load([test_object,'_test_set.mat']);     %load test set.

    fvals=zeros(1,modelcount); 
    for i=0:modelcount
      [acc(i+1),fval]=lsvm_test_engine(i,test_set,test_object);
      if (i~=0)
          fvals(1,i)=fval;
      end
    end

    plot([1:modelcount],acc(2:modelcount+1));
    grid on;
    hold on;
    %axis([1,modelcount,0,1]);
    %plot([1:modelcount],acc(0)*ones(1,2:modelcount+1),'r');
    line([1,modelcount+2],[acc(1),acc(1)],'Color','r','LineWidth',2);

    figure;
    grid on;
    hold on;
    plot([1:modelcount],fvals);
    saveas(gcf,['figures/ITEINFO_',test_object,'MODELCOUNT_',num2str(modelcount),'.fig']);
end
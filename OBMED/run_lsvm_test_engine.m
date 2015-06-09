function []=run_lsvm_test_engine(test_object,model_folder)
   %test_object:designate the action type for test.
   % clear all;
    clc;
    acc=[];
    
    word=177;

    t=dir([model_folder,'/',test_object,'/']);
    modelcount=size(t,1)-3;
    disp(['modelcount=',num2str(modelcount)]);

    % load('lsvm_rand_row.mat');    %load rand row info.
     load(['/home/liujiang/',test_object,'_test_set_177.mat']);     %load test set.

    fvals=zeros(1,modelcount); 
    
    %call lsvm_test_engine for each models in iteration and acquire 
    %their accuracy and object function value, respectively.
    for i=0:modelcount
      
      [acc(i+1),fval]=lsvm_test_engine(i,test_set,test_object,word,model_folder);
      disp([num2str(i),'-th model, acc:',num2str(acc(i+1))]);
      if (i~=0)
          fvals(1,i)=fval;
      end
    end
    
    
    
    save(['figures/',test_object,'_Word_',num2str(word),'_AP_RAW_OB177.mat'],'acc');
    %modelcount=6;
    
    figure;
    plot(1:modelcount,acc(2:modelcount+1));
    grid on;
    hold on;
   % axis([1,modelcount,0,1]);
%    plot(1:modelcount,acc(0)*ones(1,modelcount+1),'r');
    line([1,modelcount+2],[acc(1),acc(1)],'Color','r','LineWidth',2);  %the baseline: AP of the default pooling strategy.
    
    saveas(gcf,['figures/AP_',test_object,'_word_',num2str(word),'_MODELCOUNT_',num2str(modelcount),'_OB177.fig']);
    
    
    figure;
    grid on;
    hold on;
    plot(1:modelcount,fvals);
    saveas(gcf,['figures/ITEINFO_',test_object,'_word_',num2str(word),'_MODELCOUNT_',num2str(modelcount),'_OB177.fig']);
end
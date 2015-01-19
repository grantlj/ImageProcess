%test engine for our lsvm model.
function [accuracy,fval] = lsvm_test_engine(itecount,test_set,test_object)
addpath(genpath('libsvm-3.18/'));
  try
      make
  catch
      disp('Error compiling libsvm...');
      pause;
  end
 
 
 %itecount=1;                    %select models at ite count of n.
 load(['lsvm_model/',test_object,'_1vN_Models_After_ITE_',num2str(itecount),'.mat']);   %load models.
 try
   fval=model.fval;
 catch
    fval=inf;
 end
 success=0; total=0;
 
 datacount=1;
 tests=test_set{datacount}.tests;
 test_label=test_set{datacount}.label;
 featureCount=size(tests,2);
 
 score=[];
 for i=1:featureCount
   feat=tests{i};     %raw feat for each video.
   if (isempty(feat))
      continue;
   end
      
   total=total+1;
   thetaMat=model.thetaMat;
   vec=thetaMat*feat;
   decision_values=model.w'*vec'+model.b;
   
   score=[score;decision_values];
   
   if (decision_values>0); max_dec_p=1; else max_dec_p=-1;end
   
   if (test_label(i,1)==max_dec_p)
      success=success+1;
   end
   
 end
 %  clc;
    disp(num2str(success/total));
    accuracy=success/total;
    
    subplot(1,2,1);
    vl_pr(test_label,score);
   % plot(recall,precision);
    subplot(1,2,2);
    vl_roc(test_label,score);
    
    saveas(gcf,['figures/AP_ROC_',test_object,'_ITE_',num2str(itecount),'.fig']);
end


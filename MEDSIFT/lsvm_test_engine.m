%test engine for our lsvm model.
function [accuracy,fval] = lsvm_test_engine(itecount,test_set,test_object,word_count,model_folder)
addpath(genpath('VLFEATROOT/'));
addpath(genpath('libsvm-3.18/'));
  try
      make;
      vl_setup;
  catch
      disp('Error compiling libsvm OR vlfeat..');
      pause;
  end
 
 
 %itecount=1;                    %select models of the n-th iteration.
 load([model_folder,'/',test_object,'_Word_',num2str(word_count),'_1vN_Models_After_ITE_',num2str(itecount),'.mat']);   %load models.
 try
  fval=0;
  for i=1:size(models,2)
      fval=fval+models{i}.fval;
  end
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
   feat0=tests{i};     %raw feat for each video.
  % feat=feat(:,1:(object_bank_word)*100);
  
   if (isempty(feat0))
      continue;
   end
   
         total=total+1;

         
    modelCount=size(models,2);
    final_decision_value=0;
    
    total_weight=0;
    
    for j=1:modelCount
       model=models{j};
       feat=feat0(:,(j-1)*100+1:(j)*100);
       thetaMat=model.thetaMat;
       
      
       %first we get the actual feature by multiply feature matrix with
       %pooling-parameter theta.
       vec=thetaMat*feat;
       
       %get decision value by w,b in svm. >0: belongs to pos, <0 belongs to
       %nega.
       decision_values=model.w'*vec'+model.b;
       
       %Using adaboost strategies to decide weight.
       
%        if (itecount~=0)
%          eplison=sum(model.trainerr)/size(model.trainerr,2);
%          present_weight=log(sqrt((1-eplison)/(eplison)));  
%        else
           present_weight=1;
%        end
       
         total_weight=total_weight+present_weight;
       
         final_decision_value=final_decision_value+present_weight*decision_values;
 
   
    end %end of model
       
      % final_decision_value=final_decision_value/total_weight;
       if (final_decision_value>=0); max_dec_p=1; else max_dec_p=-1;end
       score=[score;final_decision_value];
       
       if (test_label(i,1)==max_dec_p)
          success=success+1;
       end
       
       
 end  %end of test set
 %  clc;
    [RECALL, PRECISION, INFOAP]=vl_pr(test_label,score);
   accuracy=INFOAP.ap;
    
   % subplot(1,2,1);
   % vl_pr(test_label,score);
   % plot(recall,precision);
   % subplot(1,2,2);
   % vl_roc(test_label,score);
    
 %   saveas(gcf,['figures/AP_ROC_',test_object,'_ITE_',num2str(itecount),'.fig']);
end


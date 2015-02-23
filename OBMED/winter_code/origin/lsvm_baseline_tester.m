%test engine for our lsvm model.
function [] = lsvm_baseline_tester(test_object)
addpath(genpath('VLFEATROOT/'));
addpath(genpath('libsvm-3.18/'));
  try
      make;
      vl_setup;
  catch
      disp('Error compiling libsvm OR vlfeat..');
      pause;
  end
 
  load([test_object,'_test_set.mat']); 
 
 %itecount=1;                    %select models of the n-th iteration.
 load(['lsvm_model/',test_object,'_1vN_BASELINE_MEAN.mat']);
 accuracy=do_test(test_set,model);
 disp(['Baseline--Mean:',num2str(accuracy)]);
 
 load(['lsvm_model/',test_object,'_1vN_BASELINE_MIN.mat']);
 accuracy=do_test(test_set,model);
 disp(['Baseline--Min:',num2str(accuracy)]);
 
 load(['lsvm_model/',test_object,'_1vN_BASELINE_MAX.mat']);
 accuracy=do_test(test_set,model);
 disp(['Baseline--Max:',num2str(accuracy)]);
end

function [accuracy]=do_test(test_set,model)
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
       %first we get the actual feature by multiply feature matrix with
       %pooling-parameter theta.
       vec=thetaMat*feat;
       %get decision value by w,b in svm. >0: belongs to pos, <0 belongs to
       %nega.
       decision_values=model.w'*vec'+model.b;
       score=[score;decision_values];
       if (decision_values>0); max_dec_p=1; else max_dec_p=-1;end
       if (test_label(i,1)==max_dec_p)
          success=success+1;
       end
 end

    [RECALL, PRECISION, INFOAP]=vl_pr(test_label,score);
    accuracy=INFOAP.ap;
end

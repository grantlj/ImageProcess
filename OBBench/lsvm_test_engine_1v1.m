%test engine for our lsvm model.
function [accuracy,fval] = lsvm_test_engine_1v1(itecount,datapath,test_set)
addpath(genpath('libsvm-3.18/'));
  try
      make
  catch
      disp('Error compiling libsvm...');
      pause;
  end
 
 
 %itecount=1;                    %select models at ite count of n.
 load(['lsvm_model/1v1_Models_After_ITE_',num2str(itecount),'.mat']);   %load models.
 try
   %fval=models{3}.fval;
   fval=[];
   for i=1:size(models,2)
     fval=[fval,models{i}.fval];
   end
 catch
    
 end
 
 success=0; total=0;
 for datacount=1:size(datapath,2)
    tests=test_set{datacount}.tests;
    test_label=test_set{datacount}.test_label;
    featureCount=size(tests,2);
    
    for i=1:featureCount
       
      feat=tests{i};     %raw feat for each video.
      if (isempty(feat))
          continue;
      end
      
      total=total+1;
      vote_result=zeros(1,size(datapath,2));
      
     % disp(num2str(size(models,2)));
      %max_dec_val=-inf; max_dec_p=1;
      for j=1:size(models,2)    %each 1v1 svm model.
        vec=[];        
       
        thetaMat=models{j}.thetaMat;
%         for k=1:size(feat,2)    %obtain the vec.
%              vec=[vec,thetaMat(k,:)*feat(:,k)];
%         end
       vec=thetaMat*feat;
        
     %  [predicted_label,accuracy,decision_values]=svmpredict(1,vec,models{j}.svmmodel);
       decision_values=models{j}.w'*vec'+models{j}.b;
       if (decision_values>=0)
          vote_result(1,models{j}.comment(1,1))= vote_result(1,models{j}.comment(1,1))+1;
       
       else
         vote_result(1,models{j}.comment(1,2))= vote_result(1,models{j}.comment(1,2))+1;
      end
       

      end  %end of vote.
      
    %  pause;
      
      maxlabel=find(vote_result==max(max(vote_result)));   %get max label in vote result.
      if (~isempty(find(test_label(i)==maxlabel)))         %if correct label is in maxlabel, then classification correct!
        success=success+1;
      end
   end

 end

  %  clc;
  disp(num2str(success/total));
  accuracy=success/total;
end

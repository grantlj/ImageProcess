%test engine for our lsvm model.
%33.3%
function [accuracy] = lsvm_test_engine(itecount)
addpath(genpath('libsvm-3.18/'));
  try
      make
  catch
      disp('Error compiling libsvm...');
      pause;
  end
 datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'};
%   datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'...
%             'dataset/brush_hair/','dataset/catch/','dataset/clap/','dataset/climb_stairs/'...
%             'dataset/golf/','dataset/jump/','dataset/kick_ball/','dataset/pour/','dataset/pullup/'...
%             'dataset/push/','dataset/shoot_ball/','dataset/shoot_bow/','dataset/shoot_gun/','dataset/sit/'...
%             'dataset/stand/','dataset/swing_baseball/'}; %search path;
% row_dim=44604;
 
% load('lsvm_rand_row.mat');    %load rand row info.
 load('lsvm_test_set.mat');     %load test set.
 
 %itecount=1;                    %select models at ite count of n.
 load(['lsvm_model/Models_After_ITE_',num2str(itecount),'.mat']);   %load models.
 
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
    %  vote_result=zeros(1,size(datapath,2));
      
      max_dec_val=-inf; max_dec_p=1;
      for j=1:size(datapath,2)    %each 1vN svm model.
        vec=[];        
       
        thetaMat=models{j}.thetaMat;
%         for k=1:size(feat,2)    %obtain the vec.
%              vec=[vec,thetaMat(k,:)*feat(:,k)];
%         end
       vec=thetaMat*feat;
        
       %[predicted_label,accuracy,decision_values]=svmpredict(1,vec,models{j}.svmmodel);
       decision_values=models{j}.w'*vec'+models{j}.b;
       if (decision_values>max_dec_val)
           max_dec_val=decision_values;
           max_dec_p=j;
       end
       
%        if (predicted_label==1)
%            vote_result(1,j)=vote_result(1,j)+1;
%        else
%            vote_result(1,:)=vote_result(1,:)+1;
%            vote_result(1,j)=vote_result(1,j)-1;
%        end
%        
      end  %end of vote.
      
%       maxlabel=find(vote_result==max(max(vote_result)));   %get max label in vote result.
%       if (~isempty(find(test_label(i)==maxlabel)) && size(maxlabel,2)<=3)         %if correct label is in maxlabel, then classification correct!
      if (test_label(i)==max_dec_p)
          success=success+1;
      end
    end
 end
 %  clc;
    disp(num2str(success/total));
    accuracy=success/total;
end


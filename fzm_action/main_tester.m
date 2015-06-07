function main_tester()

  %feature_path.
  bow_path={'D:/dataset/fzm_action/frame_bow/boxing/',...
            'D:/dataset/fzm_action/frame_bow/handclapping/',...
            'D:/dataset/fzm_action/frame_bow/handwaving/',...
            'D:/dataset/fzm_action/frame_bow/normal/'};
        
  total_video_count=61;
  train_video_count=41;
  
  pooling_frames=20;      %every pooling_frames frame as a block.
%%
% loading training set.
  train_set=[];
  train_label=[];
  for i=1:size(bow_path,2)
      
    for j=1:train_video_count
       feature_filename=[bow_path{i},num2str(j),'_feat_bow.mat'];  
       [now_train_set,now_train_label]=extract_feat_from_file(feature_filename,i,pooling_frames);
       train_set=[train_set;now_train_set];
       train_label=[train_label;now_train_label];
    end
      
  end  %end of i, classes.
  
%%
%loading test set.
  test_set=[];
  test_label=[];
  for i=1:size(bow_path,2)
      
    for j=train_video_count+1:total_video_count
       feature_filename=[bow_path{i},num2str(j),'_feat_bow.mat'];  
       [now_test_set,now_test_label]=extract_feat_from_file(feature_filename,i,pooling_frames);
       test_set=[test_set;now_test_set];
       test_label=[test_label;now_test_label];
    end
      
  end  %end of i, classes.
  
%%
%train svm and test.
%[bestCVaccuarcy,bestc,bestg,pso_option] = psoSVMcgForClass(train_label,train_set)
model=svmtrain(train_label,train_set,' -c 100 -g 1000'); 
[predict_label, accuracy, decision_values] = svmpredict(test_label,test_set,model);
end


%%
function [now_train_set,now_train_label]=extract_feat_from_file(feature_filename,label,pooling_frames)
  now_train_set=[];
  now_train_label=[];
  load(feature_filename);
  
  total_frames=size(feat_bow,1);
  blocks_count=floor(total_frames/pooling_frames);
  
  for i=1:blocks_count
    tmp_feat_bow=feat_bow((i-1)*pooling_frames+1:i*pooling_frames,:);
    tmp_feat_bow=sum(tmp_feat_bow,1);
    tmp_feat_bow=tmp_feat_bow./sum(tmp_feat_bow);
    now_train_set=[now_train_set;tmp_feat_bow];
    now_train_label=[now_train_label;label];
  end

end


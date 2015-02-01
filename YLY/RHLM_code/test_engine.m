function test_engine()
    %The test engine of Web-interaction 2.0 based on semi-supervised method.
    dataset_path='dataset/';

    action_object={'chase','exchange_object','handshake','highfive','hug',...
                   'hustle','kick','kiss','pat'};

    %feature selection.
    %feature_candid={'HOF','HOG','MBHx','MBHy'};
    feature_candid={'HOF','HOG','MBHx'};

    %The ratio of train, test split.
    train_test_ratio=0.9;       

    %The ratio of label and unlabel.
    label_ratio=0.5;

    %The number of video clips in each class.
    video_count=50;
    
    labelTr=[];labelnp=[];
    %%
    %Load training and test data.
    for i=1:size(feature_candid,2)
        root_feat_path=[dataset_path,feature_candid{i},'/'];

        %Training set in featur i.
        viewsTr{i}=[];

        %Test set in feature i.
        viewsTest{i}=[];
        
        for j=1:size(action_object,2) %actions.
          action_feat_path=[root_feat_path,action_object{j},'/'];
           
          label_count=0;
          for k=1:video_count  %videoclips in one action.
             if (k<=floor(video_count*train_test_ratio))
                 %belongs to train set.
                 feat=extract_feature_fromfile(action_feat_path,k);
                 viewsTr{i}=[viewsTr{i},feat];
                 
                 if (i==1 && label_count<=floor(video_count*train_test_ratio*label_ratio))
                     %it should be labeled.
                     label_count=label_count+1;
                     labelTr=[labelTr;j];
                 elseif (i==1)
                     labelTr=[labelTr;0];
                 end  %end of if label.
             else
                 %belongs to test set.
                 feat=extract_feature_fromfile(action_feat_path,k);
                 viewsTest{i}=[viewsTest{i},feat];
                if (i==1); labelnp=[labelnp;j]; end;
             end  %end of test/train.
             
          end  %end of k
        end%end of j
    end%end of i
    
    %The diagonal matrix u:U(i,i)=1000000 if labeled, otherwise unlabeled.
    U=zeros(size(labelTr,1));
    for i=1:size(U,1)
      if (labelTr(i,1)~=0)
          %is labeled.
          U(i,i)=1000000;
      end
    end
  
  log_file_name=['object_',num2str(size(action_object,2)),'_train_ratio_',num2str(train_test_ratio*100),'_label_ratio_',num2str(label_ratio*100),'_result.txt'];
  semisupervised(viewsTr,viewsTest,U,labelTr,labelnp,log_file_name);
end

%%
%extract feature form specific file.
function [feat]=extract_feature_fromfile(action_feat_path,k)
  if (k<10) 
      filename=[action_feat_path,'00000',num2str(k),'.mat'];
  else
      filename=[action_feat_path,'0000',num2str(k),'.mat'];
  end
  load(filename);
  feat=encoding;
end
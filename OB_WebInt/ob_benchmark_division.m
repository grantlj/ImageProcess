%max-pooling: 43.2%
%mean-pooling: 
regions=2;

 feature_set_path={'feature/chase/','feature/exchange_object/',...
              'feature/handshake/','feature/highfive/',...
              'feature/hug/','feature/hustle/',...
              'feature/kick/','feature/kiss/','feature/pat/'};                                     %corresponding feature saving path.
 ret=[];
 for i=1:10  %experiment rounds.
   testid=(i-1)*5+1:i*5;
   
   train_feat=zeros(450,44604*regions);train_label=zeros(450,1);
   test_feat=zeros(50,44604*regions);test_label=zeros(50,1);
   strain=0;stest=0;
   
   for j=1:size(feature_set_path,2)
       
      for k=1:50
        filename=[feature_set_path{j},sprintf('%06d',k),'-Feature.mat'];
        load(filename);
        feature=[];
        
        frames=size(feat_raw,1);
        split_pt=floor(linspace(1,frames,regions+1));
        split_pt(1,1)=0;
        
        for reg=1:regions
          vec=-inf*ones(1,44604);vec=[vec;feat_raw(split_pt(1,reg)+1:split_pt(1,reg+1),:)];
          feature=[feature,max(vec)];       
        end
        
        if (ismember(k,testid))
            stest=stest+1;
            test_feat(stest,:)=feature;
            test_label(stest)=j;
            %is test set.   
        else
            %is train set
            strain=strain+1;
            train_feat(strain,:)=feature;
            train_label(strain)=j;
        end
            
      end
       
   end%end of j: feature_set_path
   
   %---------------------------------------------------------------------------------------------------------------------
   %                                                                                           train with SVM from libsvm
   %---------------------------------------------------------------------------------------------------------------------
     svmarg.bestc=1e200;  %default, the args are as same as that in feifei's raw code.
     svmarg.bestg=length(unique(train_label));
     model=svmtrain(train_label,train_feat,['-t 0 -g ',num2str(svmarg.bestg),' -c ',num2str(svmarg.bestc)]);
   %---------------------------------------------------------------------------------------------------------------------
   %                                                                                           test with SVM from libsvm
   %---------------------------------------------------------------------------------------------------------------------
    [predicted_label, accuracy,prob_estimate] = svmpredict(test_label, test_feat, model);
    ret = [ret,accuracy];
    
        
     
 end%end of i
 
 save(['divide_',num2str(regions),'_ret_max_pooling.mat'],'ret');





  level=19;                       %5,9,13,15,22
  %%
  %Accuracy: level 19: 32.4102%
  
  %%
  load('net-epoch-x.mat');
  data_splits_path='D:\dataset\birds\setid.mat';
  data_mean_path='D:\dataset\birds\data_mean.mat';
  truth_path='D:\dataset\birds\imagelabels.mat';
  feature_path='D:\dataset\birds\feat_1024\';
  
  load(data_splits_path);
  load(truth_path);
  load(data_mean_path);data_mean=images.data_mean;
  
  data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  net.layers{end}.type = 'softmax';
  total=0;
  %tst1=[tst1,val1,trn1];
  
  trn1=[trnid,valid];  %use both val and test set.
  truth=labels;
 'Loading training data...'
  train_feat=zeros(size(trn1,2),1024); train_label=[];  %for feature and label, respectively.
   for i=1:size(trn1,2)
     img_count=trn1(1,i);
     filename=['D:/dataset/birds/jpg/','image_',sprintf('%05d',img_count),'.jpg'];
     feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
     
     label=truth(img_count);
     
     if (~exist(feat_filename,'file'))
     im=imread(filename);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);
   %  im=gpuArray(im);
   
     
     res=vl_simplenn(net,im);
     tmp_feat=gather(res(level).x(:)');
     save(feat_filename,'tmp_feat');
     else
          load(feat_filename);
     end
         
   %  train_feat=[train_feat;tmp_feat];
      train_feat(i,:)=tmp_feat;
     train_label=[train_label;label];
%      scores = squeeze(gather(res(end).x)) ;
%      score=zeros(1,20);
%      for n=1:20
%          for i=1:size(scores,1)
%              for j=1:size(scores,2)
%                  score(n)=score(n)+scores(i,j,n);
%              end
%          end
%      end
%      
%      score=score./sum(score);
%      [bestScore, best] = max(score) ;
%      if (best==label) 
%          total=total+1;
%      end
   end
   %%
    'Loading test data...'
    tst1=tstid;
    test_feat=zeros(size(tst1,2),1024);test_label=[];
    for i=1:size(tst1,2)
     img_count=tst1(1,i);
     filename=['D:/dataset/birds/jpg/','image_',sprintf('%05d',img_count),'.jpg'];
     feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
       label=truth(img_count);
     if (~exist(feat_filename,'file'))
     
     im=imread(filename);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);
    % im=gpuArray(im);
   
     
     res=vl_simplenn(net,im);
     tmp_feat=gather(res(level).x(:)');
     save(feat_filename,'tmp_feat');
     
     else
         load(feat_filename);
     end
     
     
    % test_feat=[test_feat;tmp_feat];
     test_feat(i,:)=tmp_feat;
     test_label=[test_label;label];

    end
   %%
   %Training SVM...
   svmmodel=svmtrain(train_label,train_feat,'-s 0 -t 0');
   clear train_label;
   clear train_feat;
   [predict_label, accuracy, prob] = svmpredict(test_label, test_feat, svmmodel);

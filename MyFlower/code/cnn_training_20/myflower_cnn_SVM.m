

  level=22;                       %5,9,13,15,22
  %%
  %Result:
  %CNN only: 85.8375%
  %level 5: 74.8936%
  %level 9: 81.2766%
  %level 13: 84.6809%
  %level 15: 84.4681%
  %level 22: 86.383%
  
  %%
  load('model/net-epoch-55.mat');
  data_splits_path='datasplits.mat';
  data_mean_path='data_mean.mat';
  truth_path='truth.mat';
  
  load(data_splits_path);
  load(truth_path);
  load(data_mean_path);data_mean=images.data_mean;
  net.layers{end}.type = 'softmax';
  total=0;
  %tst1=[tst1,val1,trn1];
  
  trn1=[trn1,val1];  %use both val and test set.
  
 'Loading training data...'
  train_feat=zeros(size(trn1,2),15360); train_label=[];  %for feature and label, respectively.
   for i=1:size(trn1,2)
     img_count=trn1(1,i);
     filename=['20flowers/','image_',sprintf('%04d',img_count),'.jpg'];
     im=imread(filename);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);
     im=gpuArray(im);
     label=truth(img_count,1);
     
     res=vl_simplenn(net,im);
     tmp_feat=gather(res(level).x(:)');
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
    test_feat=zeros(size(tst1,2),15360);test_label=[];
    for i=1:size(tst1,2)
     img_count=tst1(1,i);
     filename=['20flowers/','image_',sprintf('%04d',img_count),'.jpg'];
     im=imread(filename);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);
     im=gpuArray(im);
     label=truth(img_count,1);
     
     res=vl_simplenn(net,im);
     tmp_feat=gather(res(level).x(:)');
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

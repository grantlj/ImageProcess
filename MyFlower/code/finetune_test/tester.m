function myflower_cnn_tester()
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
     
     scores = squeeze(gather(res(end).x)) ;
     score=zeros(1,20);
     for n=1:20
         for i=1:size(scores,1)
             for j=1:size(scores,2)
                 score(n)=score(n)+scores(i,j,n);
             end
         end
     end
     
     score=score./sum(score);
     [bestScore, best] = max(score) ;
     if (best==label) 
         total=total+1;
     end
   end
   
  total/size(tst1,2)
end
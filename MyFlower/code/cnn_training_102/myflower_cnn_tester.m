
  load('model/net-epoch-127.mat');
  data_splits_path='D:/dataset/oxfordflower102/setid.mat';
  data_mean_path='D:/dataset/oxfordflower102/data_mean.mat';
  truth_path='D:/dataset/oxfordflower102/imagelabels.mat';
  
  load(data_splits_path);
  load(truth_path);
  load(data_mean_path);data_mean=images.data_mean;
  net.layers{end}.type = 'softmax';
  total=0;
  %tst1=[tst1,val1,trn1];
   for i=1:size(tstid,2)
     img_count=tstid(1,i);
     filename=['D:/dataset/oxfordflower102/jpg/','image_',sprintf('%05d',img_count),'.jpg'];
     im=imread(filename);
     im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
     im=double(im)-data_mean;
     im=single(im);
     im=gpuArray(im);
     label=labels(img_count);
     
     res=vl_simplenn(net,im);
     
     scores = squeeze(gather(res(end).x)) ;
     score=zeros(1,102);
     for n=1:102
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
        % 'Yes'
     else
       %  'No'
     end
   end
   
  total/size(tstid,2)

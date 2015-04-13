%cnn_visulization
model_path='model/net-epoch-55.mat';
load(model_path);
net.layers{end}.type = 'softmax';

data_mean_path='data_mean.mat';
load(data_mean_path);data_mean=images.data_mean;

filename='test.jpg';
im=imread(filename);
im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
im=double(im)-data_mean; 
im=single(im);
im=gpuArray(im);
%label=truth(img_count,1);

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

 figure;
 level=res(15).x;
 final=[];
%set(gca, 'Units', 'normalized', 'Position', [0 0.1 0.2 0.7]);
 for i=1:16
     tmp=[];
     for j=1:16
      %   subplot(12,8,(i-1)*8+j);
      %   imshow(level(:,:,(i-1)*8+j));
        tmp=[tmp,level(:,:,(i-1)*16+j)];
     end
     final=[final;tmp];
 end
imshow(final);
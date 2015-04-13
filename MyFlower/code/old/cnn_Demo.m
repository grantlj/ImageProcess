function [] = cnn_Demo(im_path,x1,y1,x2,y2)
class_count=17;
im=imread(im_path);
data_mean_path='data_mean.mat';
load('net-epoch-45.mat');
load(data_mean_path);data_mean=images.data_mean;
net.layers{end}.type = 'softmax';
  
 try
     x1=str2num(x1);y1=str2num(y1);x2=str2num(x2);y2=str2num(y2);
     im=im(y1:y2,x1:x2,:);  %try to resize.
     disp(['BOUND OK...',num2str(x1),num2str(x2),num2str(y1),num2str(y2)]);
 catch
     disp('ERROR IN BOUND');
 end
 
  im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  im=double(im)-data_mean;
  im=single(im);
  im=gpuArray(im);
 %imshow(im);
 
 

end


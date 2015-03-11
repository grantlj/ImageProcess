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
 
 %pre-processing.
  im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  im=double(im)-data_mean;
  im=single(im);
  im=gpuArray(im);
 %imshow(im);
 
 %run cnn.
 res=vl_simplenn(net,im);
     
 scores = squeeze(gather(res(end).x)) ;
 score=zeros(1,class_count);
 for n=1:class_count
     for i=1:size(scores,1)
         for j=1:size(scores,2)
             score(n)=score(n)+scores(i,j,n);
         end
     end
 end

 score=score./sum(score);
 score(2,:)=1:class_count;
 score=score';
 score=sortrows(score,1);
 
  for i=1:5
  %   disp([get_flower_name(score(class_count-i+1,2)),' with score:',num2str(score(class_count-i+1,1))]);
     json_struct.data{i}.name=get_flower_name(score(class_count-i+1,2));
     json_struct.data{i}.prob=score(class_count-i+1,1);
  end
  % disp(['Image :',im_path,' is classified as:',get_flower_name(predict_label),' Json file saved:',json_path]);
   
   %save json string.
   json_struct.category=json_struct.data{1}.name;
   json_str=savejson('ret',json_struct,struct('ParseLogical',1));
   json_str
  % fid=fopen(json_path,'w+');
  % fprintf(fid,char(json_str));
  % fclose(fid);
 %  toc;

end


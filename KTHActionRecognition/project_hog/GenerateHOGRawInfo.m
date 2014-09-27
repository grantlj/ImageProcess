%返回某一视频文件的HOG-RAW结构体
function [ret]=GenerateHOGRawInfo(destFile)
   %destFile='boxing\person01_boxing_d1_uncomp.avi';
   vl_setup;
   obj=VideoReader(destFile);  %得到的是一个object
   vidFrames=read(obj);     %得到的是所有帧的数据
   numFrames=obj.numberOfFrames;  %所有帧的数量
   ret={};
   cellSize=12;
   %disp(['*****File: ',destFile,' SIFT Raw calculating...']);
   for i=1:round(numFrames/3)                                  %每3帧采样一次
     mov(i).cdata=vidFrames(:,:,:,i*3-1);                                
     mov(i).cdata=rgb2gray(mov(i).cdata);                                
     mov(i).cdata=single(mov(i).cdata);  
     hog=vl_hog(mov(i).cdata,cellSize);
     ret{i}=hog;
   end
 %  disp(['*****File: ',destFile,' FINISHED.']);

end
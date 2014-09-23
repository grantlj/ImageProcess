%返回某一视频文件的SIFT-RAW结构体
function [ret]=GenerateSiftRawInfo(destFile)
   %destFile='boxing\person01_boxing_d1_uncomp.avi';
   vl_setup;
   obj=VideoReader(destFile);  %得到的是一个object
   vidFrames=read(obj);     %得到的是所有帧的数据
   numFrames=obj.numberOfFrames;  %所有帧的数量
   ret={};
   %disp(['*****File: ',destFile,' SIFT Raw calculating...']);
   for i=1:round(numFrames/2)                              %每2帧采样一次
     mov(i).cdata=vidFrames(:,:,:,i*2-1);                                
     mov(i).cdata=rgb2gray(mov(i).cdata);                                
     mov(i).cdata=single(mov(i).cdata);  
     [f,d]=vl_sift(mov(i).cdata);                           %得到SIFT信息
     ret(i).f=f;
     ret(i).d=d;
   end
 %  disp(['*****File: ',destFile,' FINISHED.']);

end
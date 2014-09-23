%����ĳһ��Ƶ�ļ���SIFT-RAW�ṹ��
function [ret]=GenerateSiftRawInfo(destFile)
   %destFile='boxing\person01_boxing_d1_uncomp.avi';
   vl_setup;
   obj=VideoReader(destFile);  %�õ�����һ��object
   vidFrames=read(obj);     %�õ���������֡������
   numFrames=obj.numberOfFrames;  %����֡������
   ret={};
   %disp(['*****File: ',destFile,' SIFT Raw calculating...']);
   for i=1:round(numFrames/2)                              %ÿ2֡����һ��
     mov(i).cdata=vidFrames(:,:,:,i*2-1);                                
     mov(i).cdata=rgb2gray(mov(i).cdata);                                
     mov(i).cdata=single(mov(i).cdata);  
     [f,d]=vl_sift(mov(i).cdata);                           %�õ�SIFT��Ϣ
     ret(i).f=f;
     ret(i).d=d;
   end
 %  disp(['*****File: ',destFile,' FINISHED.']);

end
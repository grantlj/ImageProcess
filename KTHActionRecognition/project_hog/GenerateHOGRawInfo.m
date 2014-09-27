%����ĳһ��Ƶ�ļ���HOG-RAW�ṹ��
function [ret]=GenerateHOGRawInfo(destFile)
   %destFile='boxing\person01_boxing_d1_uncomp.avi';
   vl_setup;
   obj=VideoReader(destFile);  %�õ�����һ��object
   vidFrames=read(obj);     %�õ���������֡������
   numFrames=obj.numberOfFrames;  %����֡������
   ret={};
   cellSize=12;
   %disp(['*****File: ',destFile,' SIFT Raw calculating...']);
   for i=1:round(numFrames/3)                                  %ÿ3֡����һ��
     mov(i).cdata=vidFrames(:,:,:,i*3-1);                                
     mov(i).cdata=rgb2gray(mov(i).cdata);                                
     mov(i).cdata=single(mov(i).cdata);  
     hog=vl_hog(mov(i).cdata,cellSize);
     ret{i}=hog;
   end
 %  disp(['*****File: ',destFile,' FINISHED.']);

end
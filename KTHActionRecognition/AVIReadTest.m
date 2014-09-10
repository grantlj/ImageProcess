function [] = AVIReadTest()
  destFile='D:\Matlab\ImageProcess\KTHActionRecognition\running\person01_running_d1_uncomp.avi';
  obj=VideoReader(destFile);  %得到的是一个object
  vidFrames=read(obj);     %得到的是所有帧的数据
  numFrames=obj.numberOfFrames;  %所有帧的数量
  disp(numFrames);
  for i=1:numFrames
      mov(i).cdata=vidFrames(:,:,:,i);
  end
  
  %{
   figure;
   imshow(mov(100).cdata);
   figure;
   imshow(mov(round(30)).cdata);
   figure;
   imshow(mov(round(210)).cdata);
  %}
  
end


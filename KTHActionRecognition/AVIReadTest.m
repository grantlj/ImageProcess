function [] = AVIReadTest()
  destFile='D:\Matlab\ImageProcess\KTHActionRecognition\running\person01_running_d1_uncomp.avi';
  obj=VideoReader(destFile);  %�õ�����һ��object
  vidFrames=read(obj);     %�õ���������֡������
  numFrames=obj.numberOfFrames;  %����֡������
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


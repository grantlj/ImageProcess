function []=showAndCopyFile(filename,fmt)
  instance=imread(filename,fmt);
  
  posOfDot=findstr(filename,'.');   %�ҵ���չ���Ǹ����λ��
  p=posOfDot(1,size(posOfDot,2));   %size���ص��Ǵ�С [M N] 
  filename2=[filename(1:posOfDot-1),'copy',filename(posOfDot:size(filename,2))]; %�ַ������� �ļ�������һ��copy
  imshow(instance,[0,80]);
  disp(filename2);
  imwrite(instance,filename2,fmt);
end

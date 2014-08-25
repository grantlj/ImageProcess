function []=showAndCopyFile(filename,fmt)
  instance=imread(filename,fmt);
  
  posOfDot=findstr(filename,'.');   %找到拓展名那个点的位置
  p=posOfDot(1,size(posOfDot,2));   %size返回的是大小 [M N] 
  filename2=[filename(1:posOfDot-1),'copy',filename(posOfDot:size(filename,2))]; %字符串连接 文件名最后加一个copy
  imshow(instance,[0,80]);
  disp(filename2);
  imwrite(instance,filename2,fmt);
end

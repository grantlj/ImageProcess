function []=ImageRotation(filename)
  l_origin=imread(filename);
  l_r1=imrotate(l_origin,60,'bilinear','loose');
  l_r2=imrotate(l_origin,60,'bilinear','crop');
  subplot(1,3,1);
  %title('original');
  imshow(l_origin);
  subplot(1,3,2);
  %title('loose');
  imshow(l_r1);
  subplot(1,3,3);
  %text('crop');
  imshow(l_r2);
end
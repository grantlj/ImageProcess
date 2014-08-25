function []=ShearTransform(filename)
  l_origin=imread(filename);
  subplot(1,2,1);
  imshow(l_origin);
  
  l_new=zeros(2*size(l_origin));
  TFORM=maketform('affine',[cos(45),sin(45),0;-sin(45),cos(45),0;0,0,1]);
  l_new=imtransform(l_origin,TFORM);
  subplot(1,2,2);
  imshow(l_new);
end
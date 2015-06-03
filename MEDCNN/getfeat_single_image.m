function [feat]=getfeat_single_image(im,net)
  level=42;
  im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  im=double(im)-net.normalization.averageImage;
  im=single(im);
  im=gpuArray(im);
  res=vl_simplenn(net,im);
  feat=gather(res(level).x(:)');
  %size(feat)
  %pause;
end



function []=TopHatTest(filename)
  l_origin=imread(filename);
  figure;
  imshow(l_origin);
  l_open=imopen(l_origin,strel('disk',5)); %������
  l_tophat=imsubtract(l_origin,l_open);    %ԭͼ-������=��ñ�任
  figure;
  imshow(l_open);
  figure;
  l_tophat=imadjust(l_tophat);
  imshow(l_tophat);
end
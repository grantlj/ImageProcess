function []=AddNoise(filename)
  l_origin=imread(filename);
  l_gauss=imnoise(l_origin,'gaussian',0.5,0.2); %�������������� ��˹�ֲ�����ֵ�ͱ�׼��
  l_sp=imnoise(l_origin,'salt & pepper',0.3);
  subplot(1,3,1);
  imshow(l_origin);
  subplot(1,3,2);
  imshow(l_gauss);
  subplot(1,3,3);
  imshow(l_sp);
end
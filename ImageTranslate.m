function []=ImageTranslate(filename)
  l_origin=imread(filename);
  %���Գ���ת���ɻҶ�ͼ ������
  l_origin=rgb2gray(l_origin);
 % optreg=translate(strel('square',30),[20 10]);   %translateֻ������ƽ�ƽṹԪ�ص� Ҳ����ˢ�ӵ�λ�� 30������ 40 ����
 %ע�� ������Ǽ򵥵�ѡ��strelΪԭͼ�ߴ� ����Ԥ�ϵ��������൱�Ĵ� ��һ��O(N^4)���㷨
 optreg=strel('ball',5,10); 
 l_new=imdilate(l_origin,optreg);
 figure;
  subplot(1,3,1);
  imshow(l_origin);
  subplot(1,3,2);
  imshow(l_new);
  subplot(1,3,3);
  l_new2=imdilate(l_new,optreg);
  imshow(l_new2);
  disp('finish');
end
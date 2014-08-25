function []=ImageTranslate(filename)
  l_origin=imread(filename);
  %可以尝试转换成灰度图 更明显
  l_origin=rgb2gray(l_origin);
 % optreg=translate(strel('square',30),[20 10]);   %translate只是用来平移结构元素的 也就是刷子的位置 30：向左 40 向上
 %注意 如果我们简单的选择strel为原图尺寸 可以预料到计算量相当的大 是一个O(N^4)的算法
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
function []=findFaceFeatures(filename)
  im_origin=imread(filename);
  im_origin_bw=im2bw(im_origin,0.38);
  %im_origin_gray=rgb2gray(im_origin);
  
  brush=strel('ball',4,4);
  im_afterclose=imclose(im_origin,brush);
  im_afterclose_gray=rgb2gray(im_afterclose);
  im_afterclose_bw=im2bw(im_afterclose_gray,0.43);
  
  subplot(2,2,1);
  imshow(im_origin_bw);
  subplot(2,2,2);
  imshow(im_afterclose_bw);
  
  %亦或运算 并求坐标均值
  im_xor=bitxor(im_origin_bw,im_afterclose_bw);
  [m,n]=size(im_xor);
  xinfo=[0,0];
  yinfo=[0,0];
  for i=1:m
      for j=1:n
          if (im_xor(i,j)==1)
             xinfo=xinfo+[i,1];
             yinfo=yinfo+[j,1]; 
          end
      end
  end
  avg_x=xinfo(1)/xinfo(2);avg_y=yinfo(1)/yinfo(2);
 
  for i=round(avg_x-5):round(avg_x+5)
      for j=round(avg_y-5):round(avg_y+5)
          im_origin(i,j,:)=0;
          im_origin(i,j,1)=255;
      end
  end
  subplot(2,2,3);
  imshow(im_origin);
  
  %对bw图提取连通分量 试图找到五官等分割部分
  [L,num]=bwlabel(im_origin_bw,8);
  
  %初始化叠加层待用的显示函数
  rnd_color=round(rand(num,3)*240)+15;
  disp(rnd_color);
  
  
  [m,n]=size(L);
  disp(L);
  cover=zeros(m,n,3);
  for i=1:m
      for j=1:n
          if (L(i,j)~=0)
            cover(i,j,:)=rnd_color(L(i,j),:);
            %disp(rnd_color(L(i,j)));
          end
      end
  end
  
  subplot(2,2,4);
  cover=uint8(cover);
  imshow(cover(:,:,:));
  
end
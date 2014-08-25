function []=HoughLineDetector(filename)
  l_origin=imread(filename);
  l_gray=rgb2gray(l_origin);
  l_gray=medfilt2(l_gray,[2,2]);               %中值滤波消除噪点
  l_gray=im2bw(l_gray,graythresh(l_gray));     %转化为二值图像
  l_gray=imopen(l_gray,strel('diamond',4));    %使用菱形做开运算 进一步粗化直线
 
  figure;
  imshow(l_gray);
  
  figure;
  [H,T,R]=hough(l_gray);                       %hough变换 
  
  
   P=houghpeaks(H,5,'threshold',0.6*max(H(:))); %houghpeak，找峰值，此处找5条出来 默认60%的点在上面才是直线
   imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');   %显示hough变换结果
   xlabel('\theta'), ylabel('\rho');
   axis on, axis normal, hold on;
   plot(T(P(:,2)),R(P(:,1)),'s','color','red');                      %将5个高亮区域标出来
   
   %将5条线标出来
   lines = houghlines(l_gray,T,R,P,'FillGap',5,'MinLength',7);
   figure;
   imshow(l_origin);hold on;
   
    for k = 1:length(lines)
        %xy是起始点和终止点的集合
         xy = [lines(k).point1; lines(k).point2];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');   %在两点之间连线
 
         % plot beginnings and ends of lines
         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end;
end
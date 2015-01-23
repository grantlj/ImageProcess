function [hough_space,hough_circle,para] = do_hough_circle(BW,step_r,step_angle,r_min,r_max,p)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input
% BW:二值图像；
% step_r:检测的圆半径步长
% step_angle:角度步长，单位为弧度
% r_min:最小圆半径
% r_max:最大圆半径
% p:阈值，0，1之间的数 通过调此值可以得到图中圆的圆心和半径
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output
% hough_space:参数空间，h(a,b,r)表示圆心在(a,b)半径为r的圆上的点数
% hough_circl:二值图像，检测到的圆
% para:检测到的圆的圆心、半径

circleParaXYR=[];
para=[];

[m,n] = size(BW);
size_r = round((r_max-r_min)/step_r)+1;%四舍五入
size_angle = round(2*pi/step_angle);

hough_space = zeros(m,n,size_r);

[rows,cols] = find(BW);%查找非零元素的行列坐标
ecount = size(rows);%非零坐标的个数

% Hough变换
% 将图像空间(x,y)对应到参数空间(a,b,r)

% a = x-r*cos(angle)
% b = y-r*sin(angle)

for i=1:ecount
    for r=1:size_r %半径步长数
        for k=1:size_angle %按一定弧度把圆几等分
            a = round(rows(i)-(r_min+(r-1)*step_r)*cos(k*step_angle));
            b = round(cols(i)-(r_min+(r-1)*step_r)*sin(k*step_angle));
            if(a>0&a<=m&b>0&b<=n)
            hough_space(a,b,r) = hough_space(a,b,r)+1;%h(a,b,r)的坐标，圆心和半径
            end
        end
    end
end


% 搜索超过阈值的聚集点。对于多个圆的检测，阈值要设的小一点！通过调此值，可以求出所有圆的圆心和半径
max_para = max(max(max(hough_space)));%返回值就是这个矩阵的最大值
index = find(hough_space>=max_para*p);%一个矩阵中，想找到其中大于max_para*p数的位置
length = size(index);%符合阈值的个数
hough_circle = false(m,n);
%hough_circle = zeros(m,n);
%通过位置求半径和圆心。
for i=1:ecount
    for k=1:length
        par3 = floor(index(k)/(m*n))+1;
        par2 = floor((index(k)-(par3-1)*(m*n))/m)+1;
        par1 = index(k)-(par3-1)*(m*n)-(par2-1)*m;
        if((rows(i)-par1)^2+(cols(i)-par2)^2<(r_min+(par3-1)*step_r)^2+5&...
                (rows(i)-par1)^2+(cols(i)-par2)^2>(r_min+(par3-1)*step_r)^2-5)
              hough_circle(rows(i),cols(i)) = true;   %检测的圆
        end
    end
end               

% 从超过峰值阈值中得到
for k=1:length
    par3 = floor(index(k)/(m*n))+1;%取整
    par2 = floor((index(k)-(par3-1)*(m*n))/m)+1;
    par1 = index(k)-(par3-1)*(m*n)-(par2-1)*m;
    circleParaXYR = [circleParaXYR;par1,par2,par3];
    hough_circle(par1,par2)= true; %这时得到好多圆心和半径，不同的圆的圆心处聚集好多点，这是因为所给的圆不是标准的圆
    %fprintf(1,'test1:Center %d %d \n',par1,par2);
end

%集中在各个圆的圆心处的点取平均，得到针对每个圆的精确圆心和半径！
while size(circleParaXYR,1) >= 1
    num=1;
    XYR=[];
    temp1=circleParaXYR(1,1);
    temp2=circleParaXYR(1,2);
    temp3=circleParaXYR(1,3);
    c1=temp1;
    c2=temp2;
    c3=temp3;
    temp3= r_min+(temp3-1)*step_r;
   if size(circleParaXYR,1)>1     
     for k=2:size(circleParaXYR,1)
      if (circleParaXYR(k,1)-temp1)^2+(circleParaXYR(k,2)-temp2)^2 > temp3^2
         XYR=[XYR;circleParaXYR(k,1),circleParaXYR(k,2),circleParaXYR(k,3)];  %保存剩下圆的圆心和半径位置
      else  
      c1=c1+circleParaXYR(k,1);
      c2=c2+circleParaXYR(k,2);
      c3=c3+circleParaXYR(k,3);
      num=num+1;
      end 
    end
   end 
      %fprintf(1,'sum %d %d radius %d\n',c1,c2,r_min+(c3-1)*step_r);
      c1=round(c1/num);
      c2=round(c2/num);
      c3=round(c3/num);
      c3=r_min+(c3-1)*step_r;
      %fprintf(1,'num=%d\n',num)
      %fprintf(1,'Center %d %d radius %d\n',c1,c2,c3);   
      para=[para;c1,c2,c3]; %保存各个圆的圆心和半径的值
      circleParaXYR=XYR;
end
function ellipse_fitting()
clear all;
clc;

n=10;
canvas=ones(500,500)*255;
imshow(canvas);


%select points on canvas.
global pts;
pts=ginput(n);

center_x=mean(pts(:,1));
center_y=mean(pts(:,2));

pts(:,1)=pts(:,1)-center_x;
pts(:,2)=pts(:,2)-center_y;
%ellipse equation
%ax^2+bxy+cy^2+dx+ey=f
args=rand(1,6)*pts(1,1);

opts = optimoptions(@fmincon,'MaxFunEvals',2000,'Algorithm','sqp');
[args, fval, exitflag]=fmincon(@func_opt,...
                                 args,...
                                 [],[],...
                                 [],[],...
                                 [],...
                                 [],...
                                 @func_con,opts);

str=[num2str(args(1,1)),'*x^2+',num2str(args(1,2)),'*x*y+',num2str(args(1,3)),'*y^2+',num2str(args(1,4)),'*x+',num2str(args(1,5)), '*y=',num2str(args(1,6))];
%str=[num2str(args(1,1)),'*x^2+',num2str(args(1,2)),'*y^2-',num2str(args(1,3)),'*x*y=1'];
figure;
     

hold on;
for i=1:n
  hold on;
  plot(pts(i,1),pts(i,2),'*');
end
ezplot(str);                    
end

function f=func_opt(args)
  global pts;
  err=0;
  for i=1:size(pts,1)
      str=[num2str(args(1,1)),'*x^2+',num2str(args(1,2)),'*x*',num2str(pts(1,2)),'+',num2str(args(1,3)),'*',num2str(pts(1,2)),'^2+',num2str(args(1,4)),'*x+',num2str(args(1,5)), '*',num2str(pts(1,2)),'=',num2str(args(1,6))];
      s=solve(str)
      s=double(s);
    %  err=err+norm(min((s(1,1)-pts(i,1))^2,(s(2,1)-pts(i,1))^2));
      err=err+norm((s(1,1)-pts(i,1))^2)+norm(s(2,1)-pts(i,1)^2);
  end
  f=err^2;
%  f=err+0.2*norm(args);
end


function [c ceq]=func_con(args)
  %b^2-4ac>0
  c=-4*args(1,1)*args(1,3)+args(1,2)*args(1,2); 
  %c(1)=-args(1,1);
 % c(2)=-args(1,2);
  %c(3)=-args(1,3);
  ceq=[];
end
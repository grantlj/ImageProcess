function []=GaborFilter()
%绘制一个Gabor滤波器的空域和频域函数图
%这东西说白了就是高斯和三角函数调制。能很好地提取边缘模拟视觉的感受视野。
clear;
x = 0;
theta = 0;
f0 = 0.2;
for i = linspace(-15,15,50)
    x = x + 1;
    y = 0;
    for j = linspace(-15,15,50)
        y = y + 1;
        z(y,x)=compute(i,j,f0,theta);
    end
end
x = linspace(-15,15,50);
y = linspace(-15,15,50);
surf(x,y,real(z))
title('Gabor filter:real component');
xlabel('x');
ylabel('y');
zlabel('z');
figure(2);
surf(x,y,imag(z))
title('Gabor filter:imaginary component');
xlabel('x');
ylabel('y');
zlabel('z');

Z = fft2(z);
u = linspace(-0.5,0.5,50);
v = linspace(-0.5,0.5,50);
figure(3);
surf(u,v,abs(fftshift(Z)))
title('Gabor filter:frequency component');
xlabel('u');
ylabel('v');
zlabel('Z');
end

function gabor_k = compute(x,y,f0,theta)
r = 1; g = 1;
x1 = x*cos(theta) + y*sin(theta);
y1 = -x*sin(theta) + y*cos(theta);
gabor_k = f0^2/(pi*r*g)*exp(-(f0^2*x1^2/r^2+f0^2*y1^2/g^2))*exp(i*2*pi*f0*x1); 
end
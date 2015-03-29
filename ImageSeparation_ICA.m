%%
%The mixing job.

s1=imread('D:\im1.jpg');
s2=imread('D:\im2.jpg');

subplot(2,2,1);imshow(s1);
subplot(2,2,2);imshow(s2);

beta=1/5;
%Trans Matrix. We can conduct SVD and ICA on it.
A=[4/5 beta;1/2 2/3];

%Do composition.
x1=double(A(1,1)*s1+A(1,2)*s2);
x2=double(A(2,1)*s1+A(2,2)*s2);

subplot(2,2,3);imshow(uint8(x1));
subplot(2,2,4);imshow(uint8(x2));

%%
%First, we need to calculate the variance of A.(find the maximum and
%minimum of the DIRECTION of A!

%First reshape it to vector.
[m,n]=size(x1);
x1=reshape(x1,m*n,1);
x2=reshape(x2,m*n,1);

x1=x1-mean(x1);
x2=x2-mean(x2);

%%
%Calculate the main direction. We suppose the maximux variation direction
%is the data direction.
theta0=0.5*atan(-2*sum(x1.*x2)/sum(x1.^2-x2.^2)); %in radius.

%Rotation Matrix U, exactly one of the SVD component of A.
Us=[cos(theta0) sin(theta0);-sin(theta0) cos(theta0)];

%%
%Calcualate the scaling matrix, sigma.
sig1=sum((x1*cos(theta0)+x2*sin(theta0)).^2);
sig2=sum((x1*cos(theta0-pi/2)+x2*sin(theta0+pi/2)).^2);

sigma=[1/sqrt(sig1) 0;0 1/sqrt(sig2)];

%%
%Now it is time for the V matrix.
x1bar=sigma(1,1)*(Us(1,1)*x1+Us(1,2)*x2);
x2bar=sigma(2,2)*(Us(2,1)*x1+Us(2,2)*x2);
x1bar=reshape(x1bar,m*n,1);
x2bar=reshape(x2bar,m*n,1);

phi0=0.25*atan( -sum((x1bar.^3).*x2bar-2*x1bar.*(x2bar.^3))      )/sum( 3*(x1bar.^2).*(x2bar.^2)-0.5*(x1bar.^4)-0.5*(x2bar.^4));
V=[cos(phi0)  sin(phi0); -sin(phi0) cos(phi0)];
%%
s1bar=V(1,1)*x1bar+V(1,2)*x2bar;  %reconstructed s1
s2bar=V(2,1)*x1bar+V(2,2)*x2bar;  %reconstructed s2



min1=min(min(min(s1bar)));
s1bar=s1bar-min1;
max1=max(max(max(s1bar)));
s1bar=s1bar*(255/max1);
s1_re=reshape(s1bar,m,n/3,3);


min2=min(min(min(s2bar)));
s2bar=s2bar-min2;
max2=max(max(max(s2bar)));
s2bar=s2bar*(255/max2);
s2_re=reshape(s2bar,m,n/3, 3);


figure;
subplot(1,2,1);imshow(uint8(s1_re));
subplot(1,2,2);imshow(uint8(s2_re));



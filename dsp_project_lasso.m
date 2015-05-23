function [] = dsp_project_lasso()
global A; global y;
%M is the length of the signal.
M=500; 

%N is the sampling points in freq domain.
N=1000;

%t0 is the sampling interval.
t0=0.02;
%%
%t is the sampling points.
t=0:0.02:(M-1)*0.02;

%s is the pure signal.
s=10*sin(3*t)+8*cos(15*t);

%plot the original signal.
subplot(4,1,1);

plot(t,s);
title('original signal s(t)');
%%
%w is the gaussian noise.
gaussian_mean=0.5; gaussian_sigma=2;
w=normrnd(gaussian_mean,gaussian_sigma,1,M);
y=s+w;

%plot the noise-contaminated signal.
subplot(4,1,2);

plot(t,y);
title('noise contaminated signal y(t)');

%generate the observation matrix(DFT matrix) (M*N).
A=dftmtx(N);
A=A(1:M,:);

%%
%prepare to solve the lasso optimization problem using fminunc.
y=y';
c_init=rand(N,1);
options = optimoptions('fminunc','Display','iter-detailed','Algorithm','quasi-newton');
[c,fval,exitflag]=fminunc(@code_opt,c_init,options);
%%
%plot the reconstructed singal.
y_re=(A*c)';
subplot(4,1,3);
plot(t,y_re);
title('reconstructed signal');

%plot the residual.
res=abs(s-y_re);
subplot(4,1,4);
plot(t,res);
title('error');
end

%%
function f=code_opt(c_now)
  global y; global A;
  residual=y-A*c_now;
  lamda=1;
  f=norm(residual,2)+lamda*norm(c_now,1); %using L2-norm will cause overfitting problem
end


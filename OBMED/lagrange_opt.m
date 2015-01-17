%lagrange intrporation function for raw feature.
function [feat_new] = lagrange_opt(feat_raw)
 % load('dataset/pick/#122_Cleaning_Up_The_Beach_In_Chiba__Japan_pick_f_nm_np1_fr_bad_1.avi-Feature.mat')
  feat_raw=sort(feat_raw,1,'descend'); %sort by column, each column means one object at one dimension and block. 
  
  Ti=size(feat_raw,1);   %frame count before interporation,
  
  T=20;  %temporary value;
  feat_new=[];
  for i=1:size(feat_raw,2)
    feat_now=feat_raw(:,i);  %take out the i-th column;
    x0=[1:size(feat_now,1)]; y0=feat_now'; x=floor(linspace(1,Ti,T));
  %  stem(x0,y0,'r*');hold on;
    y=lagrange(x0,y0,x)';
    feat_new=horzcat(feat_new,y);  %一行一个lagrange化后的feature
 %   plot(x,y);
  end
end

%Lagrange interpolation function, x0,y0 are inputs(already known), x is
%what we want know.
function y=lagrange(x0,y0,x)
n=length(x0);m=length(x);
for i=1:m
  z=x(i);
  s=0.0;
  for k=1:n
      p=1.0;
      for j=1:n
          if j~=k
            p=p*(z-x0(j))/(x0(k)-x0(j));
          end
      end
      s=p*y0(k)+s;
  end
  y(i)=s;
 end
end

X=rand(3,4);
covX=cov(X);
[V,D]=eig(covX);
[newD,IX] = sort(diag(D),'descend');
newD=diag(newD);
newV=V(:,IX);
V=newV; D=newD;
clear newV;
clear newD;

Y=X*V;
[coef,score,latent,t2] = princomp(X);

Y
score
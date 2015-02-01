function L = Laplacian_LRGA(X, para)

k = para.k;

lamda = para.lamda;

% lamda  can be tuned from [0.1,10,1000];
% X is the training set with m*n, where n is the number of observations

[Dim, n] = size(X);

Lc = eye(k) - 1/k*ones(k);

A = spalloc(n*k,n*k,5*n*k);

S = spalloc(n,n*k,5*n*k);

for i = 1:n

    dis = repmat(X(:,i),1,n) - X;

    dis = sum(dis.*dis);

    [dumb, nnidx] = sort(dis);

    Xi = X(:,nnidx(1:k));

    Xi = Xi*Lc;

    if Dim > k

        Ai = inv(lamda*eye(k) + Xi'*Xi);

        Ai = lamda*Lc*Ai*Lc;

    else

        Ai = Lc - Xi'*inv(lamda*eye(Dim) + Xi*Xi')*Xi;

    end;

    lidx = (i-1)*k+1:(i-1)*k+k;

    A(lidx, lidx) = Ai;

    S(nnidx(1:k),lidx) = eye(k);

end;

L = lamda*S*A*S';
function GMKLwrapper
% Generalized Multiple Kernel Learning wrapper function.
%
% This function shows how to call COMPGDoptimize. The code is general
% and you can plug in your own kernel function and regularizer. To
% illustrate, I've included code for computing sums and products of
% RBF kernels across features based on both feature vectors and
% precomputed kernel matrices.
%
% MATLAB's quadprog will only work for small data sets. Also, I've
% only provide code for C-SVC. Note that you must have the
% optimization toolbox installed before you can use quadprog.
%
% If you would like to use LIBSVM (for SVR/SVC) instead, please 
% set parms.TYPEsolver='LIB'. In this case, you must have the 
% appropriate (modified) svmtrain.mexxxx in your path. Compiled 32 and
% 64 bit binaries for Windows and Linux are provided in
% ../LIBSVM/Binaries but you'll need to check whether they're compatible
% with your version of MATLAB. The modified source code is provided in
% ../LIBSVM/Code/libsvm-2.84-1 and you can compile that directly if you
% prefer. 
%
% You can also incorporate your favourite SVM solver by editing
% COMPGDoptimize.m.
%
% Code written by Manik Varma.


  TYPEreg=0;
  NUMkernels=2;
  data=load('toyexample');
  
  % The following code shows how to call COMPGDoptimize with
  % feature vectors as input
  %TYPEker=1;
  
  %using kernel 2.
  TYPEker=2;
  
  %初始化kernal
  parms=initparms(NUMkernels,TYPEker,TYPEreg);
  fprintf('Learning products of RBF kernels subject to l1 regularization [using feature vectors].\n');
  
  
  %其实真正调用也就这一行？
  %按照列存放
  svm=COMPGDoptimize(data.TRNfeatures,data.TRNlabels,parms);   %10 training set. two feature.
  fprintf('At this point, svm.d shold be [1.020 0.353]''\n');
  svm.d
  
  % The following code shows how to use the learnt svm for classifying
  % test data.
  K=parms.fncK(data.TRNfeatures(:,svm.svind),data.TSTfeatures,parms,svm.d);
  predict=sign(svm.b+svm.alphay'*K)';
  accuracy=100*mean(predict==data.TSTlabels);
  fprintf('Classification accuracy on the test set = %6.2f%%\n',accuracy);
  fprintf('Press any key to continue ...\n');pause;clc;
  
  % The following code shows how to call COMPGDoptimize with
  % precomputed matrices as input
  %global Dprecomp;
  
  global Kprecomp;
  
  TYPEker=3;
  parms=initparms(NUMkernels,TYPEker,TYPEreg);
  %Dprecomp=precomp(data.TRNfeatures,data.TRNfeatures);
  Kprecomp=precomp(data.TRNfeatures,data.TRNfeatures);
  fprintf('Learning products of RBF kernels subject to l1 regularization [using pre-computed distance matrices].\n');
  svm=COMPGDoptimize([1:size(data.TRNfeatures,2)],data.TRNlabels,parms);
  fprintf('At this point, svm.d shold be [1.020 0.353]''\n');
  svm.d   %d is the parameter we want to learn.

  % The following code shows how to use the learnt svm for classifying
  % test data.
  %Dprecomp=precomp(data.TRNfeatures,data.TSTfeatures);
  Kprecomp=precomp(data.TRNfeatures,data.TRNfeatures);
  K=parms.fncK(svm.svind,[1:size(data.TSTfeatures,2)],parms,svm.d);
  predict=sign(svm.b+svm.alphay'*K)';
  accuracy=100*mean(predict==data.TSTlabels);
  fprintf('Classification accuracy on the test set = %6.2f%%\n',accuracy);  
end


%初始化，返回d？
function D=precomp(TRNfeatures,TSTfeatures)
  [NUMk,NUMtrain]=size(TRNfeatures);
  [NUMk,NUMtest]=size(TSTfeatures);
  D=zeros(NUMtrain,NUMtest,NUMk);
  for k=1:NUMk, D(:,:,k)=(repmat(TRNfeatures(k,:)',1,NUMtest)-repmat(TSTfeatures(k,:),NUMtrain,1)).^2; end;
end

function parms=initparms(NUMk,TYPEker,TYPEreg)
  % Kernel parameters
  switch (TYPEker),
    case 0, parms.KERname='Sum of RBF kernels across features';
            parms.gamma=ones(NUMk,1);
	    parms.fncK=@KSumRBF;
	    parms.fncKdash=@KdashSumRBF;
	    parms.fncKdashint=@KdashSumRBFintermediate;
    case 1, parms.KERname='Product of RBF kernels across features';
            parms.gamma=1;
	    parms.fncK=@KProdRBF;
	    parms.fncKdash=@KdashProdRBF;
	    parms.fncKdashint=@KdashProdRBFintermediate;
        
    %linear kernel???
    case 2, parms.KERname='Sum of precomputed kernels';
	    parms.fncK=@KSumPrecomp;
	    parms.fncKdash=@KdashSumPrecomp;
	    parms.fncKdashint=@KdashSumPrecompintermediate;
    case 3, parms.KERname='Product of exponential kernels of precomputed disance matrices';
            parms.gamma=1;
	    parms.fncK=@KProdExpPrecomp;
	    parms.fncKdash=@KdashProdExpPrecomp;
	    parms.fncKdashint=@KdashProdExpPrecompintermediate;
    otherwise, fprintf('Unknown kernel type.\n'); keyboard; 
  end;
      
  % Regularization parameters
  switch (TYPEreg),
    case 0, parms.REGname='l1';          % L1 Regularization
            parms.sigma=ones(NUMk,1);
	    parms.fncR=@Rl1;
	    parms.fncRdash=@Rdashl1;
    case 1, parms.REGname='l2';          % L2 Regularization
            parms.mud=ones(NUMk,1);
	    parms.covd=1e-1*eye(NUMk);
	    parms.invcovd=inv(parms.covd);
	    parms.fncR=@Rl2;
	    parms.fncRdash=@Rdashl2;
    otherwise, fprintf('Unknown regularisation type.\n'); keyboard; 
  end;
    
  % Standard SVM parameters
  parms.TYPEprob=0;           % 0 = C-SVC, 3 = EPS-SVR (try others at your own risk)
  parms.C=10;                 % Misclassification penalty for SVC/SVR ('-c' in libSVM)
  
  % Gradient descent parameters
  
  %哦 这个d就是那个参数，initd就是初始值。
  parms.initd=rand(NUMk,1);   % Starting point for gradient descent
  parms.TYPEsolver='LIB';     % Use Matlab's quadprog as an SVM solver.
  parms.TYPEstep=1;           % 0 = Armijo, 1 = Variant Armijo, 2 = Hessian (not yet implemented)
  parms.MAXITER=40;           % Maximum number of gradient descent iterations
  parms.MAXEVAL=200;          % Maximum number of SVM evaluations
  parms.MAXSUBEVAL=20;        % Maximum number of SVM evaluations in any line search
  parms.SIGMATOL=0.3;         % Needed by Armijo, variant Armijo for line search
  parms.BETAUP=2.1;           % Needed by Armijo, variant Armijo for line search
  parms.BETADN=0.3;           % Needed by variant Armijo for line search
  parms.BOOLverbose=true;     % Print debug information at each iteration
  parms.SQRBETAUP=parms.BETAUP*parms.BETAUP;    
end

function r=Rl1(parms,d), r=parms.sigma'*d; end
function rdash=Rdashl1(parms,d), rdash=parms.sigma; end

function r=Rl2(parms,d), delta=parms.mud-d;r=0.5*delta'*parms.invcovd*delta; end
function rdash=Rdashl2(parms,d), rdash=parms.invcovd*(d-parms.mud); end

function K=KSumRBF(TRNfeatures,TSTfeatures,parms,d)
  [NUMdims,NUMtrn]=size(TRNfeatures);
  [NUMdims,NUMtst]=size(TSTfeatures);
  if (NUMdims~=length(d)), fprintf('NUMdims not equal to NUMk\n'); keyboard; end;
  
  nzind=find(d>1e-4);
  K=zeros(NUMtrn,NUMtst);
  if (~isempty(nzind)),
    for i=1:length(nzind),
      k=nzind(i);
      Dk=(repmat(TRNfeatures(k,:)',1,NUMtst)-repmat(TSTfeatures(k,:),NUMtrn,1)).^2;
      K=K+d(k)*exp(-parms.gamma(k)*Dk);
    end;
  end;
end

function Kdashint=KdashSumRBFintermediate(TRNfeatures,TSTfeatures,parms,d)
  Kdashint=[];
end

function Kdash=KdashSumRBF(TRNfeatures,TSTfeatures,parms,d,k,Kdashint)
  [NUMdims,NUMtrn]=size(TRNfeatures);
  [NUMdims,NUMtst]=size(TSTfeatures);

  Kdash=exp(-parms.gamma(k)*(repmat(TRNfeatures(k,:)',1,NUMtst)-repmat(TSTfeatures(k,:),NUMtrn,1)).^2);
end

%这个很重要！！！！！！
%这下面一堆全是核函数相关！！！！！！！！！！
function K=KProdRBF(TRNfeatures,TSTfeatures,parms,d)
  [NUMdims,NUMtrn]=size(TRNfeatures);
  [NUMdims,NUMtst]=size(TSTfeatures);
  if (NUMdims~=length(d)), fprintf('NUMdims not equal to NUMk\n'); keyboard; end;
  
  nzind=find(d>1e-4);
  K=zeros(NUMtrn,NUMtst);
  if (~isempty(nzind)),
    for i=1:length(nzind),
      k=nzind(i);
      
      %这个地方就是算RBF核？放到一个mat里面！？
      K=K+d(k)*(repmat(TRNfeatures(k,:)',1,NUMtst)-repmat(TSTfeatures(k,:),NUMtrn,1)).^2;
    end;
  end;
  K=exp(-parms.gamma*K);
end

function Kdashint=KdashProdRBFintermediate(TRNfeatures,TSTfeatures,parms,d)
  Kdashint=-parms.gamma*parms.fncK(TRNfeatures,TSTfeatures,parms,d);
end

function Kdash=KdashProdRBF(TRNfeatures,TSTfeatures,parms,d,k,Kdashint)
  [NUMdims,NUMtrn]=size(TRNfeatures);
  [NUMdims,NUMtst]=size(TSTfeatures);

  Kdash=Kdashint.*(repmat(TRNfeatures(k,:)',1,NUMtst)-repmat(TSTfeatures(k,:),NUMtrn,1)).^2;
end

%%
function K=KSumPrecomp(TRNfeatures,TSTfeatures,parms,d)
  global Kprecomp;
  if (size(Kprecomp,3)~=length(d)), fprintf('Number of kernels does not equal number of weights.\n');keyboard; end;

  K=lincomb(Kprecomp(TRNfeatures,TSTfeatures,:),d);
end

function Kdashint=KdashSumPrecompintermediate(TRNfeatures,TSTfeatures,parms,d)
  Kdashint=[];
end

function Kdash=KdashSumPrecomp(TRNfeatures,TSTfeatures,parms,d,k,Kdashint)
  global Kprecomp;
  
  Kdash=Kprecomp(TRNfeatures,TSTfeatures,k);
end
%%


function K=KProdExpPrecomp(TRNfeatures,TSTfeatures,parms,d)
  %global Dprecomp;
  %if (size(Dprecomp,3)~=length(d)), fprintf('Number of kernels does not equal number of weights.\n');keyboard; end;

  %K=exp(-parms.gamma*lincomb(Dprecomp(TRNfeatures,TSTfeatures,:),d));
  
  global Kprecomp;
  if (size(Kprecomp,3)~=length(d)), fprintf('Number of kernels does not equal number of weights.\n');keyboard; end;

  K=exp(-parms.gamma*lincomb(Kprecomp(TRNfeatures,TSTfeatures,:),d));
end

function Kdashint=KdashProdExpPrecompintermediate(TRNfeatures,TSTfeatures,parms,d)
  Kdashint=-parms.gamma*parms.fncK(TRNfeatures,TSTfeatures,parms,d);
end

function Kdash=KdashProdExpPrecomp(TRNfeatures,TSTfeatures,parms,d,k,Kdashint)
  %global Dprecomp;
  global Kprecomp;
 % Kdash=Kdashint.*Dprecomp(TRNfeatures,TSTfeatures,k);
  Kdash=Kdashint.*Kprecomp(TRNfeatures,TSTfeatures,k);
end

function K=lincomb(base,d)
  nzind=find(d>1e-4);
  K=zeros(size(base,1),size(base,2));
  if (~isempty(nzind)), for k=1:length(nzind), K=K+d(nzind(k))*base(:,:,nzind(k)); end; end;
end

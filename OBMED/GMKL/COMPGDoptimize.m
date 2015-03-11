function svm=COMPGDoptimize(features,labels,parms)
% Generalized Multiple Kernel Learning via projected gradient descent. 
%
% svm=COMPGDoptimize(features,labels,parms)
% 
% Inputs:
%   features - NUMdims x NUMtrainpts matrix of training feature
%              vectors. If you are using precomputed kernels then 
%              set features=[1:NUMtrainpts];
%   labels   - NUMtrainpts x 1 vector of training labels. For
%              classification, use +1 and -1 for the positive and
%              negative class respectively.
%   parms    - structure specifying algorithm parameters. Look at
%              PGDwrapper for details on setting these parameters.
% Output:
%   svm      - structure containing the learnt SVM, kernel parameters
%              d and diagnostic information. During testing, first
%              form the kernel matrix using the learnt parameters svm.d and
%              then just use the standard SVM decision function, typically
%              f(x) = svm.b + svm.alphay'*K(svm.svind,x_i) as you
%              would have done for classification, regression or
%              novelty detection.
%
% Known issues:
% * In some cases, the support vector coefficients calculated by
% LIBSVM might not be precise enough to perform accurate gradient
% descent. This means that the gradient descent algorithm will 
% not converge no matter how many iterations you let it run for. If it
% is crucial that you have the exact settings of the kernel parameters then you
% should switch to MATLAB or some other optimiser. You could also
% modify the LIBSVM code to return higher precision alphas. However, for most
% applications, the exact kernel parameters are not needed. In fact,
% early termination of the gradient descent is often advised.
%
% * Because of numerical imprecisions in calculating the gradient, the
% algorithm will sometimes drift towards the origin (all d are zero)
% and will throw an exception (which you can catch). To fix
% this, you might want to change your parameter settings, or try a
% different initialisation or, as a drastic measure, switch to
% quadprog. 
% 
% * LIBSVM can hang when passed an abnormal kernel matrix including
% ones with very small or very large values.
%
% * LIBSVM can flip the sign of the learnt decision function if the
% first training label is not positive. You might want to rearrange
% your training data so as avoid this bug.
%
% * The cache size is set to 500 Mb. Tune as appropriate for your
% application. 
%
% Code written by Manik Varma.

  [curpt,diagnostic]=PGDoptimize(features,labels,parms);
  Kopt=parms.fncK(features(:,curpt.svind),features,parms,curpt.d);
  svm=calSVMparms(curpt,Kopt,diagnostic,labels,parms);
end

function [curpt,diagnostic]=PGDoptimize(features,labels,parms)
  tic;
  iter=0;
  step=1;
  evals=1; % Used during initialisation
  BOOLstep0=false;
  curpt=initcurpt(features,labels,parms);
  stoptol=1e-9*curpt.pgm2;
  while (curpt.pgm2>stoptol && iter<parms.MAXITER && evals<parms.MAXEVAL && ~BOOLstep0),
    if (step>parms.SQRBETAUP), step=parms.BETADN; end; 
    if (parms.BOOLverbose), printstats(iter,evals,step,curpt,[]); end;
    [newpt,step,subiter,BOOLstep0,evals]=steparmijo(curpt,features,labels,parms,step,evals);
    if ((parms.TYPEstep==1) && (subiter==1)),
      [curpt,step,evals]=stepvararmijo(curpt,newpt,features,labels,parms,step,evals);
    else curpt=newpt; end;
    iter=iter+1;
  end;  
  BOOLconv=curpt.pgm2<=stoptol;
  BOOLtimeout=iter>=parms.MAXITER || evals>=parms.MAXEVAL;
  diagnostic=buildiagnostic(step,iter,evals,toc,parms.initd,BOOLconv,BOOLtimeout,BOOLstep0);
end

function [valpt,step,evals]=stepvararmijo(curpt,valpt,features,labels,parms,step,evals)
  iter=0;
  BOOLloop=true;
  rhs=parms.SIGMATOL*curpt.pgm2;
  while ((BOOLloop) && (evals<parms.MAXEVAL)),
    iter=iter+1;evals=evals+1;
    newstep=step*parms.BETAUP;
    newd=max(curpt.d-newstep*curpt.grad,0);
    newpt=solvesubprob(newd,features,labels,parms);
    BOOLloop=(newpt.cost<=curpt.cost-newstep*rhs);
    if (BOOLloop), valpt=newpt; step=newstep; end;
  end;
  valpt.grad=gradsubprob(valpt,features,labels,parms);
  valpt.pgm2=projgradmagsqr(valpt);
end

function [newpt,step,iter,BOOLstep0,evals]=steparmijo(curpt,features,labels,parms,step,evals)
  iter=0;
  newpt.cost=+Inf;
  rhs=parms.SIGMATOL*curpt.pgm2;
  while ((newpt.cost>curpt.cost-step*rhs) && (iter<parms.MAXSUBEVAL) && (evals<parms.MAXEVAL)),
    newpt=solvesubprob(max(curpt.d-step*curpt.grad,0),features,labels,parms);
    iter=iter+1;evals=evals+1;
    step=step*parms.BETADN;
  end;
  step=step/parms.BETADN; % Due to one extra iteration
  BOOLstep0=(iter>=parms.MAXSUBEVAL);
  if (newpt.cost<curpt.cost),
    newpt.grad=gradsubprob(newpt,features,labels,parms);
    newpt.pgm2=projgradmagsqr(newpt); 
  else newpt=curpt; end;
end

function curpt=solvesubprob(d,features,labels,parms)
  if strcmpi(parms.TYPEsolver,'LIB'), curpt=LIBsolvesubprob(d,features,labels,parms);
  elseif strcmpi(parms.TYPEsolver,'MAT'), curpt=MATsolvesubprob(d,features,labels,parms);
  else fprintf('Unknown SVM solver requested.\n'); keyboard; end;
end

function curpt=MATsolvesubprob(d,features,labels,parms)
  NUMpts=size(features,2);
  if (all(abs(d)<1e-5)),
    curpt.cost=Inf;
    curpt.svind=[1:NUMpts]';
    curpt.alphay=[];
    curpt.b=Inf;
    curpt.d=d;
  else
    Kopt=parms.fncK(features,features,parms,d);
    if (parms.TYPEprob==0),
      Y=diag(labels);
      H=Y*Kopt*Y;
      f=-ones(NUMpts,1);            % -\sigma{\alpha_{i}} in Wolfe dual
      Aeq=labels';                  % Constraint \sigma{\alpha_{i} labels_{i}} == 0
      beq=0;
      LB=zeros(NUMpts,1);           % Lower Bound: \alpha_{i} >= 0
      UB=repmat(parms.C,NUMpts,1);  % Upper Bound: \alpha_{i} <= C
      X0=zeros(NUMpts,1);           % Starting point set to 0
      OPTIONS=optimset('Display','off','LargeScale','off','MaxIter',2000);
      [alpha,minval,exitflag,output]=quadprog(H,f,[],[],Aeq,beq,LB,UB,X0,OPTIONS);
      if (exitflag<1), error('MKL:QPerr',output.message); end;
      
      EPS=1e-5;
      svind=find(alpha>EPS);
      bind=find((alpha>EPS) & (alpha<parms.C-EPS));
      if (length(svind)<2), error('MKL:SVerr','Less than 2 support vectors found.'); end;
      if (isempty(bind)), fprintf('All alpha stuck at C. Inspect Kopt*Y*alpha to set bind (bind=svind?).\n'); keyboard; end;

      curpt.d=d;
      curpt.svind=svind;
      curpt.alphay=alpha(svind).*labels(svind);
      curpt.b=mean(labels(bind).*(1-H(bind,:)*alpha));
    else error('Matlab solver only available for C-SVC'); end;
    curpt.cost=parms.fncR(parms,d)-minval;
  end;
end

function curpt=LIBsolvesubprob(d,features,labels,parms)
  if all(abs(d)<1e-5),
    curpt.cost=Inf;
    curpt.svind=[]';
    curpt.alphay=[];
    curpt.b=Inf;
    curpt.d=d;        
  else
    Kopt=parms.fncK(features,features,parms,d);
    libSVMK=[(1:size(Kopt,1))' Kopt];
    libSVMstr=sprintf('-s %d -t 4 -m 500',parms.TYPEprob);
    switch parms.TYPEprob,
    case 0, libSVMstr=sprintf('%s -c %f',libSVMstr,parms.C);
    case 1, libSVMstr=sprintf('%s -n %f',libSVMstr,parms.nu);
    case 2, libSVMstr=sprintf('%s -n %f',libSVMstr,parms.nu);
    case 3, libSVMstr=sprintf('%s -c %f -p %f',libSVMstr,parms.C,parms.eps); 
    case 4, libSVMstr=sprintf('%s -c %f -n %f',libSVMstr,parms.C,parms.nu);
    end;
    
    [model,cost]=svmtrain(labels,libSVMK,libSVMstr);
    if (isempty(model.SVs)), error('MKL:LIBerr','LIBSVM error: No support vectors found.'); end;
        
    curpt.cost=parms.fncR(parms,d)-cost;
    curpt.svind=full(model.SVs);
    curpt.alphay=model.sv_coef;
    curpt.b=-model.rho;
    curpt.d=d;
  end;
end

function curpt=initcurpt(features,labels,parms)
  curpt=solvesubprob(parms.initd,features,labels,parms);
  curpt.grad=gradsubprob(curpt,features,labels,parms);
  curpt.pgm2=projgradmagsqr(curpt); % Projected gradient magnitude sqr for termination.
end

function grad=gradsubprob(curpt,features,labels,parms)
  grad=parms.fncRdash(parms,curpt.d);
  svx=features(:,curpt.svind);
  Kdashint=parms.fncKdashint(svx,svx,parms,curpt.d);
  for k=1:length(curpt.d), 
    Kdashk=parms.fncKdash(svx,svx,parms,curpt.d,k,Kdashint);
    grad(k)=grad(k)-0.5*curpt.alphay'*Kdashk*curpt.alphay; 
  end;
end

function pgm2=projgradmagsqr(curpt)
  projgrad=curpt.grad;
  ind=find(curpt.d<1e-4);
  projgrad(ind)=min(0,projgrad(ind));
  pgm2=projgrad'*projgrad;
end

function diagnostic=buildiagnostic(step,iter,evals,deltat,initd,BOOLconverged,BOOLtimeout,BOOLstep0)
  diagnostic.step=step;
  diagnostic.iter=iter;
  diagnostic.evals=evals;
  diagnostic.time=deltat;
  diagnostic.initd=initd;
  diagnostic.BOOLstep0=BOOLstep0;
  diagnostic.BOOLtimeout=BOOLtimeout;
  diagnostic.BOOLconverged=BOOLconverged;
end

function printstats(iter,evals,step,curpt,diagnostic)
  if (isempty(diagnostic)),
    fprintf('[Starting iter %02d] Cost = %14.8f, PGM2 = %14.8f, ',iter,curpt.cost,curpt.pgm2);
    fprintf('SVM evals = %02d, Step size = %14.8f\n',evals,step);
  else
    fprintf('---------------------------------------------------\n');
    if     (diagnostic.BOOLconverged), fprintf('Optimization terminated successfully.\n');
    elseif (diagnostic.BOOLtimeout),   fprintf('Reached the maximum number of iters/evals allowed.\n');
    elseif (diagnostic.BOOLstep0),     fprintf('The step size became too small.\n'); end;
  end;
end

function svm=calSVMparms(curpt,Kopt,diagnostic,labels,parms)
  svm.b=curpt.b;
  svm.d=curpt.d;
  svm.svind=curpt.svind;
  svm.alphay=curpt.alphay;
  alphayK=svm.alphay'*Kopt;
  svm.totalcost=curpt.cost;
  svm.diagnostic=diagnostic;
  svm.margin=2/sqrt(alphayK(svm.svind)*svm.alphay);
  if ((parms.TYPEprob==0) || (parms.TYPEprob==1)),
    svm.trainclasserr=100*mean(labels'~=sign(svm.b+alphayK));
  elseif ((parms.TYPEprob==3) || (parms.TYPEprob==4))
    svm.trainRMSE=sqrt(mean((alphayK+svm.b-labels').^2));
  end;
  
  svm.diagnostic.grad=curpt.grad;
  svm.diagnostic.pgm2=curpt.pgm2;
  if (parms.BOOLverbose), printstats([],[],[],[],svm.diagnostic); end;
end

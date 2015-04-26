function [accuracy] = MKL_Learning(train_feat,train_label,test_feat,test_label)
addpath(genpath('SVM-KM'));
addpath(genpath('simplemkl'));
nbclass=102;
%----------------MKL Parameter settings-------------------
C = 100;
lambda = 1e-7;
verbose = 1;
options.algo='oneagainstone';  
options.seuildiffsigma=1e-4;
options.seuildiffconstraint=0.1;
options.seuildualitygap=1e-2;
options.goldensearch_deltmax=1e-1;
options.numericalprecision=1e-8;
options.stopvariation=1;
options.stopKKT=1;
options.stopdualitygap=0;
options.firstbasevariable='first';
options.nbitermax=500;
options.seuil=0.;
options.seuilitermax=10;
options.lambdareg = 1e-6;
options.miniter=0;
options.verbosesvm=0;
options.efficientkernel=1;
%------------------------------------------------------------

kernelt={'poly','poly'};
kerneloptionvect={[1] [1]};
variablevec={'all','all'};

[nbdata,dim]=size(train_feat);
[kernel,kerneloptionvec,variableveccell]=CreateKernelListWithVariable(variablevec,dim,kernelt,kerneloptionvect);
[Weight,InfoKernel]=UnitTraceNormalization(train_feat,kernel,kerneloptionvec,variableveccell);
K=mklkernel(train_feat,InfoKernel,Weight,options);

[beta,w,w0,pos,nbsv,SigmaH,obj] = mklmulticlass(K,train_label,C,nbclass,options,verbose);
xsup=train_feat(pos,:);

Ktest=mklkernel(test_feat,InfoKernel,Weight,options,xsup,beta);
kernel='numerical';
kerneloption.matrix=Ktest;

 [ypred,maxi] = svmmultival([],[],w,w0,nbsv,kernel,kerneloption);
 accuracy=0;
 for i=1:size(ypred,1)
   if (ypred(i)==test_label(i))
       accuracy=accuracy+1;
   end
 end
 
 accuracy=accuracy/size(ypred,1);
end


%
% Example MKL MultiClass SVM Classifiction
%
addpath(genpath('../SVM-KM'));


close all
clear all
%------------------------------------------------------
% Creating data
%------------------------------------------------------
n=20;                                                   %每种动作20个video
sigma=1.2;
nbclass=3;                                              %三个class


%生成数据
x1= sigma*randn(n,2)+ ones(n,1)*[-1.5 -1.5];            
x2= sigma*randn(n,2)+ ones(n,1)*[0 2];
x3= sigma*randn(n,2)+ ones(n,1)*[2 -1.5];

%拼接
xapp=[x1;x2;x3];

%标签1，2，3
yapp=[1*ones(1,n) 2*ones(1,n) 3*ones(1,n)]';

%n1=60,n2=2
[n1, n2]=size(xapp);
[xtesta1,xtesta2]=meshgrid([-4:0.1:4],[-4:0.1:4]);
[na,nb]=size(xtesta1);

%这个不知道在干嘛,构造测试集
xtest1=reshape(xtesta1,1,na*nb);
xtest2=reshape(xtesta2,1,na*nb);
xtest=[xtest1;xtest2]';


%----------------------------------------------------------
%   Learning and Learning Parameters
%   Parameters are similar to those used for mklsvm
%-----------------------------------------------------------

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

%这一段是核心 构造kernel
kernelt={'gaussian' 'gaussian' 'poly' 'poly' };
kerneloptionvect={[0.5 1 2 5 7 10 12 15 17 20] [0.5 1 2 5 7 10 12 15 17 20] [1 2 3] [1 2 3]};

%all就是对feature的所有维度做核。sinle就是单独对每个维度做核（作用域不同）见CerateKernelListWithVariable
%上面的optionvect是作用于all 或者 single 的整个作用域的


variablevec={'all' 'single' 'all' 'single'};


%又来size了
[nbdata,dim]=size(xapp);

%这个就是构造kernel list表
%输入：variablevec
%     dim：feature的维度
%     kernelt：核的type？
%     kerneloptionvect：核的参数？

%这里生成的kernel的维度取决于前面的all 和 single
%如果是all就加1 如果是single就加dim
[kernel,kerneloptionvec,variableveccell]=CreateKernelListWithVariable(variablevec,dim,kernelt,kerneloptionvect);

%InfoKernel里面包含了39个kernel的信息。Weight又是什么gui！！！每个kernel的初始weight吗？是的

%InfoKernel的variable决定了当前的核用什么维度！！！！给了训练集，核信息，要构造weight和kernelInfo了
%variableveccell决定了是用哪个维度
%kerneloptionvec最后是弄到了每个核里面
%optionvec的值每一个都用到了（要么是all 要么是single的model上）
[Weight,InfoKernel]=UnitTraceNormalization(xapp,kernel,kerneloptionvec,variableveccell);

%核函数矩阵60*60*39 这个mklkenel会调用svmkernel！！！！去生成相似度矩阵(对称的哦！）
K=mklkernel(xapp,InfoKernel,Weight,options);

%---------------------Learning & Testing ----------------


%这个函数是核心，K是定义了核（那个相似度矩阵），这个是计算svm参数了呵呵
[beta,w,w0,pos,nbsv,SigmaH,obj] = mklmulticlass(K,yapp,C,nbclass,options,verbose);
xsup=xapp(pos,:);

%这个是构造测试集的kernel矩阵？
Kt=mklkernel(xtest,InfoKernel,Weight,options,xsup,beta);
kernel='numerical';
kerneloption.matrix=Kt;

%这个应该就是test了吧
switch options.algo
    case 'oneagainstall'
        [ypred,maxi] = svmmultival([],[],w,w0,nbsv,kernel,kerneloption);
    case 'oneagainstone'
        [ypred,vote]=svmmultivaloneagainstone([],[],w,w0,nbsv,kernel,kerneloption);
end;


%------------------------------------------------------------------
%           Plotting the decision function
%-------------------------------------------------------------------
ypredmat=reshape(ypred,na,nb);
contour(xtesta1,xtesta2,ypredmat,[1 2 3]);hold on
style=['x+*'];
color=['bgr'];
hold on
for i=0:nbclass-1
    h=plot(xapp(i*n+1:(i+1)*n,1),xapp(i*n+1:(i+1)*n,2),[style(i+1) color(i+1)]);
    set(h,'LineWidth',2);
    hold on
end;

if ~isempty(xsup)
    h=plot(xsup(:,1),xsup(:,2),'ok');
    set(h,'LineWidth',2);
    axis( [ -4 4 -4 4]);
    legend('classe 1','classe 2','classe 3', 'Support Vector');
    hold off
end





clear;
ntrain={}; ntest={}; nclass={}; dim=44604; %use 70 for ntrain, 60 for ntest, and 8 for nclass for UIUC-Sports dataset
Ntrain=ntrain*nclass; Ntest=ntest*nclass;

trainf=zeros(Ntrain, dim);
testf=zeros(Ntest, dim);
trainl = sort(repmat((1:nclass), [1 ntrain])); testl = sort(repmat((1:nclass), [1 ntest]));
trainp = cell(1,Ntrain);
testp = cell(1,Ntest);

rootpath = {};

D = dir(rootpath);

L = length(D);
Ctrain=1; Ctest=1;
for i=3:L
	classpath = [rootpath '/' D(i).name];
	E = dir(classpath);
	M = length(E);
	rperm = randperm(M-2);

	ctrain=0; ctest=0;
	for j=1:M-2
		k = rperm(j)+2;
		featpath = [classpath '/' E(k).name];
		currfeat = load(featpath);
		currpath = [D(i).name '/' E(k).name];
		if(ctrain<ntrain), trainf(Ctrain,:) = currfeat; trainp{Ctrain} = currpath; Ctrain=Ctrain+1; ctrain=ctrain+1;
		elseif(ctest<ntest), testf(Ctest,:) = currfeat; testp{Ctest} = currpath; Ctest=Ctest+1; ctest=ctest+1;
		else, break; end
		fprintf('%d/%d %d/%d\n', Ctrain, Ntrain, Ctest, Ntest);
	end
end

save({}, 'trainf', 'testf', 'trainl', 'testl', 'trainp', 'testp');

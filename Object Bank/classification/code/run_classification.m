clear;
addpath(genpath({}));
load({});

tic;
        trainf = 1 ./ (1 + exp(-trainf_o));
        testf = 1 ./ (1 + exp(-testf_o));
toc
disp('done normalization');

tic;
        model = train(trainl, sparse(trainf), '-s 6 -c 1e200');
        [pred, prec, p]  = predict(testl, sparse(testf), model);
toc;
disp('done classification');
fprintf('prec = %f\n', prec);

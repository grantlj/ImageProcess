function [] = AdaBoost(x,y,winWidth,winLength,classifier,posMean,posStd,j,err,adaWeights,C,posMax,posMin,posErr,negErr)
% x and y are coordinates of classifier
% width and length are width and length of classifier
% featureNo is the feature being used ( 5 features only)
% posMean is the mean of the feature being used
% posStd is the standard deviation
% j is the best number of the standard deviation to use for classification
% err is the error to calculate alpha
% adaWeights are the current weights of Adaboost for each image
% C contains information about which images were classified correctly and
% which were not by writting a zero to correctly classified and 1 for
% incorrectly classified
disp('Using Adaboost on weak classifier');
bestClassFile = 'C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\Face Detect Software\vars\Classifiers.mat';
classifiers = open(bestClassFile);
classifiers = classifiers.classifiers;
alpha = 1/2*(log((1-err)/err));
i = 1:max(size(adaWeights));
adaWeights(i) = adaWeights(i).*exp(alpha*C(i));
adaWeights = adaWeights/ sum(adaWeights);
weightsFile = 'C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\Face Detect Software\vars\weights.mat';
save(weightsFile,'-double','adaWeights');
% need to write next classifier information by first getting the size of
% the columns
[M N] =size(classifiers);
classifiers(1,N+1) = x; % classifier window x start value
classifiers(2,N+1) = y; % classifier window y start value
classifiers(3,N+1) = winWidth;  % classifier window width
classifiers(4,N+1) = winLength; % classifier window length
classifiers(5,N+1) = classifier;    % 1 - 5 number to denote classifier No
classifiers(6,N+1) = posMean;   % mean of images for this classifier
classifiers(7,N+1) = posStd;    % std of images
classifiers(8,N+1) = posMax;    % max value of positive images
classifiers(9,N+1) = posMin;    % min value of positive images
classifiers(10,N+1) = j;         % (max/50)*j && (min/50)*j is the window of best classification
classifiers(11,N+1) = alpha;     % alpha that should be multiplied choosen by Adaboost
classifiers(12,N+1) = err;      % error of this classifier
classifiers(13,N+1) = posErr;   % False negative error
classifiers(14,N+1) = negErr;   % False positive error
save(bestClassFile,'classifiers');
fprintf('x start value: %e\n',x);
fprintf('y start value: %e\n',y);
fprintf('Width: %e\n',winWidth);
fprintf('Length: %e\n',winLength);
fprintf('classifier: %e\n',classifier);
fprintf('Mean value: %e\n',posMean);
fprintf('Std value: %e\n',posStd);
fprintf('Max value: %e\n',posMax);
fprintf('Min value: %e\n',posMin);
fprintf('This number multiplied by min/50 and max/50 gives best thresh: %e\n',j);
fprintf('alpha: %e\n',alpha);
fprintf('error: %e\n',err);
fprintf('False Negative error: %e\n',posErr);
fprintf('False positive error: %e\n',negErr);
disp('Weights have been changed');
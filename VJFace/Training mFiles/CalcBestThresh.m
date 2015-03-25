function [] = CalcBestThresh(x,y,winWidth,winLength,classifier)
PosImgSize = 2429;
NegImgSize = 4547;
totalSize = PosImgSize + NegImgSize;
threshPos = zeros(1,PosImgSize);
threshNeg = zeros(1,NegImgSize);
% open a weights mat file that contains current weights of Ada boost for
% each image
weightsFile = 'C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\Face Detect Software\vars\weights.mat';

adaWeights = open(weightsFile);
adaWeights = adaWeights.adaWeights;
% for every face image, calculate the haar feature (over 51000 haar
% features for a 19 x 19 window)
disp('Evaluating images using CalcBestThresh');
for i=1:PosImgSize
    str = strcat('C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\MIT CBCL Image set\train\VarianceFaces\',int2str(i),'.pgm');
    eval('img = imread(str);');
    threshPos(i) = HaarFeatureCalc(img,x,y,winWidth,winLength,classifier);
end
% get mean and std of the face images to use as our classifier
posMean = mean(threshPos);
posStd = std(threshPos);
posMax = max(threshPos);
posMin = min(threshPos);
% for every non face image, calculate the haar feature
for i=1:NegImgSize
    str = strcat('C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\MIT CBCL Image set\train\VarianceNonFaces\',int2str(i),'.pgm');
    eval('img = imread(str);');
    threshNeg(i) =  HaarFeatureCalc(img,x,y,winWidth,winLength,classifier);
end
% look for best threshold of points between mean and std of face images for
% each classifier
disp('Finished evaluating all images at specified classifier');
disp('Looking for best threshold, thresholds are:');
thresh = [threshPos threshNeg]
for j = 1:50
    % calculate false positives ( WE REALLY DONT WANT THESE)
    pos = 0;
    % calculate false positives (NOT SO IMPORTANT, but must be below 50%)
    neg = 0;
    C = ones(1,totalSize);
    % Increase the bandwitdh of our gaussian distribution to accept more
    % recognition outside the mean to get a probability with almost 100%
    % face detection with a low (65% or less) non face recognition and a
    % total error lower than 50%. THIS IS A WEAK CLASSIFIER
    for i = 1:PosImgSize
        if (thresh(i) <=posMean +(abs(posMax -posMean)/50)*j && thresh(i) >= posMean -(abs(posMean -posMin)/50)*j)
            pos = pos+1;
            C(i) = 0;
        end
    end
    for i = 1:NegImgSize
        if (thresh(i) <=posMean +(abs(posMax -posMean)/50)*j && thresh(i) >= posMean -(abs(posMean -posMin)/50)*j)
        else
            neg = neg+1;
            C(i+PosImgSize) = 0;
        end
    end
    i = 1:totalSize;
    totalErr = sum(adaWeights(i)*C(i)');
    posErr = sum(adaWeights(1:PosImgSize)*C(1:PosImgSize)');
    negErr = sum(adaWeights(PosImgSize+1:totalSize)*C(PosImgSize+1:totalSize)');
    fprintf('Total Error: %e\n',totalErr);
    fprintf('Positive Error: %e\n',posErr);
    fprintf('Negative Error: %e\n',negErr);
    if (posErr <=0.05)
        if (totalErr<0.5)
            disp('Found weak classifier');
            fprintf('Total error is: %e\n',totalErr);
            fprintf('False Negative error: %e\n',posErr);
            fprintf('False positive error: %e\n',negErr);
            % pass to adaboost to save our weak classifier and update our
            % weights
            AdaBoost(x,y,winWidth,winLength,classifier,posMean,posStd,j,totalErr,adaWeights,C,posMax,posMin,posErr,negErr);
            break;
        end
    end
end
fprintf('Mean: %e\n',posMean);
fprintf('Std: %e\n',posStd);
fprintf('Max: %e\n',posMax);
fprintf('Min: %e\n',posMin);


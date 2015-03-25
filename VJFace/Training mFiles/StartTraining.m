function [] = StartTraining()
% Start best feature extraction by itterating
% through all points of a 19 x 19 image
% with different window sizes

% There are 5 rectangles associated with haar features
feature = [1 2; 2 1; 1 3; 3 1; 2 2];
% a window of 19 x 19 containing a face or non face
frameSize = 19;
% Total is number of training example 2429 positive
% 4547 negatives
PosImgSize = 2429;
NegImgSize = 4547;
posWeights = ones(1,PosImgSize)/PosImgSize;
negWeights = ones(1,NegImgSize)/NegImgSize;
% Weights of training set
adaWeights = [posWeights negWeights] ;
% Make adaWeights into a distribution by dividing by 2 ( 200%)
adaWeights = adaWeights / 2;
% save weights in a .mat binary file
weightsFile = 'C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\Face Detect Software\vars\weights.mat';
save(weightsFile,'-double','adaWeights');
% File associated with the best classifiers
% This will be our array having the best classifiers in Adaboost
classifiers = [0;0;0;0;0;0;0;0;0;0;0;0;0;0];
bestClassFile = 'C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\Face Detect Software\vars\Classifiers.mat';
save(bestClassFile,'classifiers');
% for each feature
for i = 1:5
    sizeX = feature(i,1);   % length
    sizeY = feature(i,2);   % width
    % for all pixels inside the boundaries of our feature
    for x=2:frameSize-sizeX
        for y=2:frameSize-sizeY
            % for each width and length possible in frameSize
            %for winLength = sizeX:sizeX:frameSize-x
             %for winWidth = sizeY:sizeY: frameSize-y;
            for winLength = sizeX:sizeX:frameSize-x
                for winWidth = sizeY:sizeY: frameSize-y;
                    disp('Send feature to calculate best threshold');
                    fprintf('x: %e\n',x);
                    fprintf('y: %e\n',y);
                    fprintf('width: %e\n',winWidth);
                    fprintf('length: %e\n',winLength);
                    fprintf('Classifier: %e\n',i)
                    CalcBestThresh(x,y,winWidth,winLength,i);
                end
            end
        end
    end
end
function [] = TestCascade();
% Opens a video in which face detection is done
%
% W contains classifier information and alpha information
W = open('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\Face Detect Software\vars\Classifiers.mat');
Weights = W.classifiers;
% sorts Weights from highest alpha to lowest (Best classifier to worst)
Weights = AlphaSort(Weights);
% Open a video and set trigger
vid=videoinput('winvideo',1);%,'YUY2_160x120');
triggerconfig(vid,'manual');
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat', Inf);
% Want to have a grayscale image
set(vid,'ReturnedColorSpace','grayscale');
%vid.FrameGrabInterval = 5;
% Will be shrinking the image to a 60 x 80
M = 60;
N = 80;
resizeImg = 1/8;
% for speed, images size been prelocated
img3 = zeros(60,80);
img2 = zeros(60,80);
img = zeros(480,640);
start(vid);
figure(1);
try
    % How many frames per call of this function
    while (vid.FramesAcquired<=30)
        tic
        trigger(vid);
        img = getdata(vid);
        img3 = imresize(img,resizeImg);
        % variance normalize our image just like training data
        img2 = varNorm(img3);
        imshow(img2);
        %imshow(img);
        hold on
        for y =2:2:N-20
            for x = 2:4:M-20;
                subimg = img2(x:x+19-1,y:y+19-1);
                %Cascade of classifiers starting by best classifiers
                % with higest alphas and ending on worst classifiers
                % with the lowest alphas
                if (CalcHaarCascade(subimg,1,3,1,Weights) ==1)
                    if (CalcHaarCascade(subimg,4,9,.7,Weights) ==1)
                        if (CalcHaarCascade(subimg,10,15,.7,Weights) ==1)
                            if (CalcHaarCascade(subimg,16,21,.6,Weights)==1)
                                if (CalcHaarCascade(subimg,22,33,.6,Weights)==1)
                                    if (CalcHaarCascade(subimg,34,49,.6,Weights)==1)
                                        if (CalcHaarCascade(subimg,50,61,.5,Weights)==1)
                                            if (CalcHaarCascade(subimg,62,81,.5,Weights)==1)
                                                if (CalcHaarCascade(subimg,82,122,.5,Weights)==1)
                                                    %rectangle('Position',[8*y 8*x 8*19 8*19],'EdgeColor','r');
                                                    rectangle('Position',[y x 19 19],'EdgeColor','r');
                                                    %disp('Face Detected');
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        toc
    end
    stop(vid)
catch
    stop(vid)
end
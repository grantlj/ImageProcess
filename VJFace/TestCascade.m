function [] = TestCascade()
% Opens a video in which face detection is done
%
close all
clear all
format long
% W contains classifier information and alpha information
W = open('C:\Users\BERTHA ACEVEDO\Desktop\MATLAB project\Face Detect Software Recent 5.25.2010\Face Detect Software\vars\Classifiers.mat');
Weights = W.classifiers;
% sorts Weights from highest alpha to lowest (Best classifier to worst)
Weights = AlphaSort(Weights);
% Open a video and set trigger
vid=videoinput('winvideo',1,'YUY2_320x240');
triggerconfig(vid,'manual');
set(vid,'FramesPerTrigger',1);
set(vid,'TriggerRepeat', Inf);
% Want to have a grayscale image
set(vid,'ReturnedColorSpace','rgb');
%vid.FrameGrabInterval = 5;
% Will be shrinking the image to a 60 x 80
resizeImg = 1/4;
% for speed, images size been prelocated
start(vid);
figure(1);
try
    % How many frames per call of this function
    while (vid.FramesAcquired<=200)
        tic
        trigger(vid);
        img = getdata(vid);
        img4 = rgb2gray(img);
        img3 = imresize(img4,resizeImg);
        % variance normalize our image just like training data
        img2 = VarNorm(img3);
        %imshow(img2);
        imshow(img);
        hold on
        for y =2:2:60
            for x = 2:2:40;
                subimg = img2(x:x+19-1,y:y+19-1);
                %Cascade of classifiers starting by best classifiers
                % with higest alphas and ending on worst classifiers
                % with the lowest alphas
                if (CalcHaarCascade(subimg,1,1,1,Weights) ==1)
                    if (  CalcHaarCascade(subimg,2,2,1,Weights) ==1)
                        if ( CalcHaarCascade(subimg,3,3,1,Weights) ==1)
                            if ( CalcHaarCascade(subimg,4,4,1,Weights) ==1)
                                if ( CalcHaarCascade(subimg,5,13,.75,Weights)==1)
                                    if ( CalcHaarCascade(subimg,14,18,.40,Weights)==1)
                                        if ( CalcHaarCascade(subimg,19,31,.7,Weights)==1)
                                            if ( CalcHaarCascade(subimg,32,56,.60,Weights)==1)
                                                if ( CalcHaarCascade(subimg,57,87,.60,Weights)==1)%ok
                                                    if ( CalcHaarCascade(subimg,88,99,.35,Weights)==1)
                                                        if ( CalcHaarCascade(subimg,100,113,.25,Weights)==1)
                                                            if ( CalcHaarCascade(subimg,114,122,.35,Weights)==1)
                                                                %                                                 if ( CalcHaarCascade(subimg,82,122,.4,Weights)==1)
                                                                %rectangle('Position',[8*y 8*x 8*19 8*19],'EdgeColor','r');
                                                                rectangle('Position',4*[y x 19 19],'EdgeColor','g');
                                                                %disp('
                                                                %Face Detected');
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
                end
            end
            toc
        end
    end
    stop(vid)
catch
    disp('Error');
    stop(vid)
end
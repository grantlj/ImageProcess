close all
img = imread('test5.jpg');
img = rgb2gray(img);
%img = imresize(img,.5);
figure,imshow(img);
hold on
% W contains classifier information and alpha information
W = open('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\Face Detect Software\vars\Classifiers.mat');
Weights = W.classifiers;
% sorts Weights from highest alpha to lowest (Best classifier to worst)
Weights = AlphaSort(Weights);
img = VarNorm(img);
for resizeThresh = 1:2
    img = imresize(img,1/2);
    [M N] = size(img);
    for y =2:2:N-20
        for x = 2:2:M-20
            subimg = img(x:x+19-1,y:y+19-1);
            if (CalcHaarCascade(subimg,1,3,.7,Weights) ==1)
                if (  CalcHaarCascade(subimg,4,9,.7,Weights) ==1)
                    if ( CalcHaarCascade(subimg,10,15,.7,Weights) ==1)
                        if ( CalcHaarCascade(subimg,16,21,.7,Weights)==1)
                            if ( CalcHaarCascade(subimg,22,33,.7,Weights)==1)
                                if ( CalcHaarCascade(subimg,34,49,.6,Weights)==1)
                                    if ( CalcHaarCascade(subimg,50,61,.6,Weights)==1)
                                        if ( CalcHaarCascade(subimg,62,81,.6,Weights)==1)
                                            if ( CalcHaarCascade(subimg,82,122,.5,Weights)==1)
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
end
hold off
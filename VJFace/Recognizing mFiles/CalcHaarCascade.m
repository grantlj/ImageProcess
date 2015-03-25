function [good] = CalcHaarCascade(subimg,Tbeginning,Tend,alphaWeight,Weights);
% subimg        -- 19 x 19 subwindow of the whole image taken
% Tbeginning    -- from which Weights column classification starts
% Tend          -- from which Weights column classification ends
% alphaWeight   -- sum of weighted recognized classifiers has to be greater
% than an alpha weight multiplied by total weights
% Weights       -- passed to this function to use its matrix values
% To determine if the classifier has classified the image as face or
% nonface.
% This function can be given from 1 classifier to all classifiers and an
% alpha weight.
good = 0;
pos_or_neg = [];
for T = Tbeginning:Tend;
    thresh(T) = HaarFeatureCalc(subimg,Weights(1,T),Weights(2,T),Weights(3,T),Weights(4,T),Weights(5,T));
    if (thresh(T) <=Weights(6,T) + abs(Weights(8,T) - Weights(6,T)).*(Weights(10,T)-5)/50)
        if (thresh(T) >=Weights(6,T) - abs(Weights(6,T) - Weights(9,T)).*(Weights(10,T)-5)/50)
            pos_or_neg(T) = 1;
        else
            pos_or_neg(T) = 0;
        end
    else
        pos_or_neg(T) = 0;
    end
end
T = Tbeginning:Tend;
if (sum(Weights(11,T).*pos_or_neg(T))>= alphaWeight*sum(Weights(11,T)))
    good = 1;
end
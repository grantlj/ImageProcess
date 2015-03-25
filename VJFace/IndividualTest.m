good = 0;
imshow(img);
hold on
for T = 2:52;%29;
        thresh(T) = HaarFeatureCalc(face,Weights(1,T),Weights(2,T),Weights(3,T),Weights(4,T),1);
    end
    if (thresh(T) <=Weights(6,T) + abs(Weights(8,T) - Weights(6,T)).*Weights(10,T)/50)
        if (thresh(T) >=Weights(6,T) - abs(Weights(6,T) - Weights(9,T)).*Weights(10,T)/50)
            pos_or_neg(T) = 1;
        else
            pos_or_neg(T) = 0;
        end
    else
        pos_or_neg(T) = 0;
    end
    WeightSum = sum(Weights(11,T)*pos_or_neg(T)')
    HalfAlpha = .5*sum(Weights(11,T))
    if (sum(Weights(11,T).*pos_or_neg(T))>= .5*sum(Weights(11,T)))
        good = good+1
        rectangle('Position',[71 21 19 19]);
    end
    hold off
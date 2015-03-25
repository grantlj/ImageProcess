function [Weights] = AlphaSort(Weights);
[OldRowNumber, NewRowNumber] = sort(Weights(11,:),'descend');
Weights = Weights(:,NewRowNumber);
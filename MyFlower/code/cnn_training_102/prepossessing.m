%pre-possessing

load('model/net-epoch-1.mat');
for i=1:size(net.layers,2)
    if (i~=20)
        net.layers{i}.filterLearningRate=0;
        net.layers{i}.biasesLearningRate=0;
        net.layers{i}.filtersWeightDecay=0;
        net.layers{i}.biasesWeightDecay=0;
    else
        net.layers{i}.filterLearningRate=1;
        net.layers{i}.biasesLearningRate=2;
        net.layers{i}.filtersWeightDecay=1;
        net.layers{i}.biasesWeightDecay=0;
    end
        
end

save('model/net-epoch-1.mat','net');
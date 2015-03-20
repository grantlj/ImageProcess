mynet=load('Copy_of_net-epoch-50.mat');
for i=1:size(net.layers,2)
    if (strcmp(net.layers{1,i}.type,'conv')==1)
        net.layers{1,i}.filters=gather(net.layers{1,i}.filters);
        net.layers{1,i}.biases=gather(net.layers{1,i}.biases);
        net.layers{1,i}.filtersMomentum=gather(net.layers{1,i}.filtersMomentum);
        net.layers{1,i}.biasesMomentum=gather(net.layers{1,i}.biasesMomentum);
    end
    
end

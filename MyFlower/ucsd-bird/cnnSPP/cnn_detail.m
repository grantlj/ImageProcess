load('net-epoch-x.mat');
layers=net.layers;
clear net;
for i=1:size(layers,2)
  now_layer=layers{i};
  if (strcmp(now_layer.type,'conv')==1)
      i
      size(now_layer.filters)
  end
    
end
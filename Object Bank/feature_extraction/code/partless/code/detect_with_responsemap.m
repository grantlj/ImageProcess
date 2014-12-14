function responsemap = detect_with_responsemap(Level, feat, scales, input, model, thresh);

L = length(Level) * model.numcomponents;
responsemap = cell(1,L);

% prepare model for convolutions
M = length(model.rootfilters);
rootfilters = cell(1,M);
for i = 1:M, rootfilters{i} = model.rootfilters{i}.w; end

% cache some data
for c = 1:model.numcomponents
  ridx{c} = model.components{c}.rootindex;
  oidx{c} = model.components{c}.offsetindex;
  root{c} = model.rootfilters{ridx{c}}.w;
  rsize{c} = [size(root{c},1) size(root{c},2)];
  numparts{c} = length(model.components{c}.parts);
end

% we pad the feature maps to detect partially visible objects
padx = ceil(model.maxsize(2)/2+1);
pady = ceil(model.maxsize(1)/2+1);

% the feature pyramid
interval=model.interval;

t=0;
for level = Level
  if size(feat{level}, 1)+2*pady < model.maxsize(1) || size(feat{level}, 2)+2*padx < model.maxsize(2), continue; end
    
  % convolve feature maps with filters 
  featr = padarray(feat{level}, [pady padx 0], 0);
  rootmatch = fconv(featr, rootfilters, 1, length(rootfilters));

  for c = 1:model.numcomponents, t=t+1; responsemap{t} = rootmatch{ridx{c}} + model.offsets{oidx{c}}.w; end
end

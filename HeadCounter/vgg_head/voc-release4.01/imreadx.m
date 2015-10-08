function im = imreadx(ex)

% Read a training example image.
%
% ex  an example returned by pascal_data.m

im = color(imread(ex.filepath));
if ex.flip
  im = im(:,end:-1:1,:);
end

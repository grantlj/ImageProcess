function im = resize_img(input, L)

input = color(input);
minlen = min([size(input, 1), size(input, 2)]);
im = imresize(double(input), L/minlen);

end

function [varImg] = VarNorm(img);
% converts the image to have a zero mean and unit variance
varImg = im2double(img);
mean_val = mean(varImg(:));
var_val = var(varImg(:));
varImg = (varImg -mean_val)/var_val;
varImg = im2uint8(mat2gray(varImg));
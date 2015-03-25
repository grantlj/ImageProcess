function [A] = IntImg(img)
% calculate the integral image of a window
A = cumsum(cumsum(double(img)),2);
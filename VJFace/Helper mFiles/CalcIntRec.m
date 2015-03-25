function [ret] = CalcIntRec(img,fourpoints)
% given four reference points in the integral image
% to calculate the sum of pixels inside it.
row_val = fourpoints(1,1);
col_val = fourpoints(1,2);
img_width = fourpoints(1,3);
img_length = fourpoints(1,4);
one = img(row_val-1,col_val-1);
two = img(row_val-1,col_val+img_width);
three = img(row_val+img_length,col_val-1);
four =  img(row_val+img_length,col_val+img_width);
ret = four + one - (two + three);
clear all;
clc;
load('C:\Users\Grant Liu\Desktop\matconvnet-fcn-master\fcn8s-cub_200_2011\imdb.mat');
for i=1:size(imdb.images.seg_pathlist,2)
   imdb.images.seg_pathlist{i}=strrep( imdb.images.seg_pathlist{i},'imagementations','segmentations'); 
    
end
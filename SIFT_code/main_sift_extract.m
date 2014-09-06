% usage: calculate the sift descriptors given the image directory
%
% inputs
% rt_img_dir    -image database root path
% rt_data_dir   -feature database root path
% gridSpacing   -spacing for sampling dense descriptors
% patchSize     -patch size for extracting sift feature
% maxImSize     -maximum size of the input image
% nrml_threshold    -low contrast normalization threshold
%
% outputs
% database      -directory for the calculated sift features
%
% Lazebnik's SIFT code is used.
%
% written by Jianchao Yang
% Mar. 2009, IFP, UIUC
%==========================================================================

rt_img_dir = '...\sift_code\Img';
rt_data_dir = '...\sift_code\sift_out';   % directory to save the sift features of the chosen dataset

% sift descriptor extraction
gridSpacing = 6;
patchSize = 16;
maxImSize = 150;
nrml_threshold = 1;                 % low contrast region normalization threshold (descriptor length)

[database, lenStat] = CalculateSiftDescriptor(rt_img_dir, rt_data_dir, gridSpacing, patchSize, maxImSize, nrml_threshold);

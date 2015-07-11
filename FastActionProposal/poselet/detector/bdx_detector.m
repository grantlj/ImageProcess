
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%% Demo file that loads an image, finds the people and draws bounding
%%% boxes around them.
%%%
%%% Copyright (C) 2009, Lubomir Bourdev and Jitendra Malik.
%%% This code is distributed with a non-commercial research license.
%%% Please see the license file license.txt included in the source directory.
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [bdxinfo]=bdx_detector(img)
global config;
config=init;
time=clock;

% Choose the category here
category = 'person';

data_root = [config.DATA_DIR '/' category];

%disp(['Running on ' category]);

faster_detection = true;  % Set this to false to run slower but higher quality
interactive_visualization = false; % Enable browsing the results
enable_bigq = true; % enables context poselets

if faster_detection
 %   disp('Using parameters optimized for speed over accuracy.');
    config.DETECTION_IMG_MIN_NUM_PIX = 500^2;  % if the number of pixels in a detection image is < DETECTION_IMG_SIDE^2, scales up the image to meet that threshold
    config.DETECTION_IMG_MAX_NUM_PIX = 750^2;
    config.PYRAMID_SCALE_RATIO = 2;
end

% Loads the SVMs for each poselet and the Hough voting params
clear output poselet_patches fg_masks;
load(['model.mat']); % model
if exist('output','var')
    model=output; clear output;
end
if ~enable_bigq
   model =rmfield(model,'bigq_weights');
   model =rmfield(model,'bigq_logit_coef');
%   disp('Context is disabled.');
end
if ~enable_bigq || faster_detection
 %  disp('*******************************************************');
 %  disp('* NOTE: The code is running in faster but suboptimal mode.');
  % disp('*       Before reporting comparison results, set faster_detection=false; enable_bigq=true;');
  % disp('*******************************************************');
end

%im1.image_file{1}=[data_root '/test.jpg'];
%im1.image_file{1}=['test2.jpg'];
%img = imread(im);

[bounds_predictions,~,~]=detect_objects_in_image(img,model,config);

if interactive_visualization && (~exist('poselet_patches','var') || ~exist('fg_masks','var'))
    disp('Interactive visualization not supported for this category');
    interactive_visualization=false;
end

%if ~interactive_visualization
    %display_thresh=5.7; % detection rate vs false positive rate threshold
    display_thresh=1.5;
   %imshow(img);
   % rectangle('position',h.bounds(:,i),'edgecolor',color,'linewidth',linewidth,'linestyle',linestyle);
   % x,y,w,h!!!!!!
   % bounds_predictions.select(bounds_predictions.score>display_thresh).draw_bounds;   %大于阈值 显示
    %torso_predictions.select(bounds_predictions.score>display_thresh).draw_bounds('blue');  %显示驱赶
    bounds_predictions=bounds_predictions.select(bounds_predictions.score>display_thresh);
    bdxinfo.total=bounds_predictions.size;
    bdxinfo.score=bounds_predictions.score;
    bdxinfo.bounds=floor(bounds_predictions.bounds);
    bdxinfo.colorhist=[];
    
    if (bdxinfo.total>0)
        disp(['bounding box found...',num2str(bdxinfo.total)]);
    end
    
    for i=1:bdxinfo.total
       x=bdxinfo.bounds(1,i);y=bdxinfo.bounds(2,i);w=bdxinfo.bounds(3,i);h=bdxinfo.bounds(4,i);
       im_patch=img(y:y+h,x:x+w,:);
       [hist_r,~]=imhist(im_patch(:,:,1));
       [hist_g,~]=imhist(im_patch(:,:,2));
       [hist_b,~]=imhist(im_patch(:,:,3));
       
       hist_r=hist_r./max(hist_r);
       hist_g=hist_g./max(hist_g);
       hist_b=hist_b./max(hist_b);
       
       bdxinfo.colorhist(:,i)=[hist_r;hist_g;hist_b];
    end
%end


end
% else
%     disp('Entering interactive visualization.');
%     params.poselet_patches=poselet_patches;
%     params.all_torso_hits=torso_predictions;
%     params.all_poselet_hits=poselet_hits;
%     params.masks=fg_masks;
% 
%     bounds_predictions.image_id(:)=1;
%     params.all_poselet_hits.image_id(:)=1;
%     params.all_torso_hits.image_id(:)=1;
%     browse_hits(bounds_predictions,im1,params);
% end

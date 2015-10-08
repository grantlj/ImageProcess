% File: demoheaddet.m
% Demo usage head detector.
%
% Requires: 
%  http://people.cs.uchicago.edu/~pff/latent-release4/
% 
% (c) Marin-Jimenez, Zisserman, Ferrari, 2012
%
% If you use this detector for your research, please, cite either:
% [1] M. Marin-Jimenez, A. Zisserman, M. Eichner, V. Ferrari
%     Detecting people looking at each other in videos  
%     International Journal of Computer Vision, 2013
%
% [2] M. Marin-Jimenez, A. Zisserman, V. Ferrari
%     "Here's looking at you, kid." Detecting people looking at each other in videos  
%     British Machine Vision Conference, 2011 
%
% - Version 2.0: this version uses by default the head detector used in IJCV'13

% Load the head detector
%load('head-gen-on-ub-4laeo-bmvc11.mat'); % BMVC'2011
%lsymbs = '<><>';
%detthr = -0.78;

load('head-gen-on-ub-4laeo.mat'); % IJCV'2013
lsymbs = '><><><';
detthr = -0.82;

% Load image
img = imread('hlayk.jpg');

%% Run head detector on the whole image: it works better on upper-body areas.
[dets, boxes] = imgdetect(img, model, detthr);

% Keep only the best ones after NMS
top = nms(dets, 0.5); 
dets = dets(top,:);

%% Draw the detections
bbox = dets(:,[1:4 end-1 end]); 

imshow(img), hold on;
axis on
for ii = 1:size(bbox,1)
   hr = rectangle('Position', [bbox(ii,1) bbox(ii,2) bbox(ii,3)-bbox(ii,1) bbox(ii,4)-bbox(ii,2)]);
   set(hr, 'EdgeColor', [1 0 0]);
   set(hr, 'LineWidth', 3);
   
   % Add direction label
   component = bbox(ii, end-1);
   str = lsymbs(component);
   ht = text(bbox(ii,1)+10, bbox(ii,2)+20 , str);
   set(ht, 'FontSize', 14);
   set(ht, 'Color', [0 0 1]);
   set(ht, 'BackgroundColor', [1 1 1]);
   set(ht, 'FontWeight', 'bold');
   
   % Add score
   str = sprintf('%.2f', bbox(ii, end));
   ht = text(bbox(ii,1)+8, bbox(ii,4)-15 , str);
   set(ht, 'FontSize', 10);
   set(ht, 'Color', [0 0.8 1]);
   %set(ht, 'BackgroundColor', [1 1 1]);
   set(ht, 'FontWeight', 'bold');
end

axis equal;
axis off;
drawnow;

print -dpng 'detections.png';

% ############################ PUBLIC DATABASE ############################
% #http://www.lara.prd.fr/benchmarks/trafficlightsrecognition 
% #(free of use for any research purpose)
% #
% #-----------------------------------------------------------------------#
% #Database provided by the *Robotics Centre, of Mines ParisTech* (France)
% #
% #File format is as follows:
% #Timestamp / frameindex x1 y1 x2 y2 id 'type' 'subtype'
% #-----------------------------------------------------------------------#
% #
% #
% #File version v 0.5

dataset_path='D:/dataset/TrafficLight/';
truth_path='D:/dataset/TrafficLight/truth.txt'; 

% delimiterIn=',';
% truth_raw=importdata(truth_path,delimiterIn);
% 
% frameInfo={};
% for i=1:size(truth_raw,1)
%   tmpstr=truth_raw{i};
%   s=regexp(tmpstr,' ','split');
%   frameInfo{i}.timeStamp=s{1};                %time stamp
%   frameInfo{i}.frame=str2num(s{3});           %frame count
%   
%   %bounding box.
%   frameInfo{i}.x1=str2num(s{4});  frameInfo{i}.y1=str2num(s{5});
%   frameInfo{i}.x2=str2num(s{6});  frameInfo{i}.y2=str2num(s{7});
%   
%   %id
%   frameInfo{i}.id=str2num(s{8});
%   
%   %type and subtype
%   frameInfo{i}.type=[s{9},s{10}]; frameInfo{i}.subtype=[s{11}];
%   
% end
% 
% save('frameInfo.mat','frameInfo');

load('frameInfo.mat');
for i=1:size(frameInfo,2)
   frameCount=frameInfo{i}.frame;
   filename=[dataset_path,'frame_',sprintf('%06d',frameCount),'.jpg'];
   im=imread(filename);
   bbox=[frameInfo{i}.x1 frameInfo{i}.y1 frameInfo{i}.x2-frameInfo{i}.x1 frameInfo{i}.y2-frameInfo{i}.y1];
   im = insertObjectAnnotation(im,'rectangle',bbox,[frameInfo{i}.type,':',frameInfo{i}.subtype]);
   imshow(im);
end

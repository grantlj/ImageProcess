%使用Vision Toolbox获取光流信息
function [] = test1_OFDemo()
  % 利用系统对象 L-K光流法检测运动
%
clc;clear all; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 创建各类系统对象
%用于读入视频的系统对象；
hvfr= vision.VideoFileReader('SampleVideo.avi',...
    'ImageColorSpace','Intensity','VideoOutputDataType','uint8');

% 用于图像数据类型转换的系统对象；
hidtc= vision.ImageDataTypeConverter;

%用于光流法检测的系统对象；
hof=vision.OpticalFlow('ReferenceFrameDelay',1);
hof.OutputValue='Horizontal and vertical components in complex form';

%用于在图像中绘制标记;
hsi=vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    'CustomBorderColor',255);

%用于播放视频图像的系统对象；
hvp = vision.VideoPlayer ('Name','Motion Vector');

while ~ isDone(hvfr)
    frame=step (hvfr);  %读入视频
    im = step (hidtc,frame); %将图像的每帧视频图像转换成单精度型
    of = step (hof,im); %用光流法对视频中的每一帧图像进行处理,我们要的就是这个of 用complex的形式表明了每个点的转移速度
    lines=videooptflowlines(of,20); %产生坐标点
    if ~ isempty(lines)
        out = step(hsi,im,lines);  %标记出光流
        step(hvp,out);  %观看检测效果
    end
end

%释放系统对象
release(hvp);
release(hvfr);

%pause;
end


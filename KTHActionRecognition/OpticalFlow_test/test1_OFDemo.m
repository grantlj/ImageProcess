%ʹ��Vision Toolbox��ȡ������Ϣ
function [] = test1_OFDemo()
  % ����ϵͳ���� L-K����������˶�
%
clc;clear all; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ��������ϵͳ����
%���ڶ�����Ƶ��ϵͳ����
hvfr= vision.VideoFileReader('SampleVideo.avi',...
    'ImageColorSpace','Intensity','VideoOutputDataType','uint8');

% ����ͼ����������ת����ϵͳ����
hidtc= vision.ImageDataTypeConverter;

%���ڹ���������ϵͳ����
hof=vision.OpticalFlow('ReferenceFrameDelay',1);
hof.OutputValue='Horizontal and vertical components in complex form';

%������ͼ���л��Ʊ��;
hsi=vision.ShapeInserter('Shape','Lines','BorderColor','Custom',...
    'CustomBorderColor',255);

%���ڲ�����Ƶͼ���ϵͳ����
hvp = vision.VideoPlayer ('Name','Motion Vector');

while ~ isDone(hvfr)
    frame=step (hvfr);  %������Ƶ
    im = step (hidtc,frame); %��ͼ���ÿ֡��Ƶͼ��ת���ɵ�������
    of = step (hof,im); %�ù���������Ƶ�е�ÿһ֡ͼ����д���,����Ҫ�ľ������of ��complex����ʽ������ÿ�����ת���ٶ�
    lines=videooptflowlines(of,20); %���������
    if ~ isempty(lines)
        out = step(hsi,im,lines);  %��ǳ�����
        step(hvp,out);  %�ۿ����Ч��
    end
end

%�ͷ�ϵͳ����
release(hvp);
release(hvfr);

%pause;
end


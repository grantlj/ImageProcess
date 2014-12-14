function getfeat_single_image(imagepath, outputfilename, outputpath, savermap)
	%这边没什么，预处理操作；
    addpath(genpath('code'));
	if ~exist('imagepath', 'var'), imagepath = 'ImageSet/4.jpg'; end
	if ~exist('outputfilename', 'var'), outputfilename = 'tmp'; end
	if ~exist('outputpath', 'var'), outputpath = outputfilename;
	else
		try
			if ~exist(outputpath), mkdir(outputpath); end
		catch
			fprintf('cannot make directory named %s\n', outputpath);
			exit(0);
		end
		outputpath = [outputpath '/' outputfilename];
	end
%         if ~exist('savermap', 'var'), savermap = 0;
%         else savermap = 1;
%         end
    savermap=1;            %保存response图;
	modelpath = 'Model/';
    
    %预处理操作结束；

	detectorlist = detectorset();      %检测器表；
    L = length(detectorlist);          %检测器个数；
	nlevel = 3; %nlevel在这里是几层spatial pyramid
    dim = 44604; interval=10; 
    nmap = 12; %nmap又是啥？这个好像很关键！和scales有关！！！！！12种不同的分辨率
    Level=(interval+1):5:(interval+30); %level又是什么乱七八糟的？

	im = imread(imagepath); %im = resize_img(im, 400);   %统一调整大小；
    imgSize=size(im);
	[feat_py, scales] = featpyramid(im, 8, 10);         %resolution?
    %反正就是做的把一张图片分成多个pyramid size of hog=8(sbin);interval is the number of scales in an octave of the pyramid.

	for l=1:L
		load([modelpath, num2str(detectorlist{l}), '_final.mat']);
        disp(num2str(detectorlist{l}));
		[bbox responsemap] = detect_with_responsemap(Level, feat_py, scales, im, model, model.thresh);  %依次载入检测器，生成responsemap和bounding box
		
%         if (size(bbox,2)>0 & max(bbox(end))>0) 
%             disp([num2str(detectorlist{l}),'HighLight!!!']);
%             pause;
%         end
        
        currfeat = cell(1,nmap);   %当前feature的结果;
        
        flag=-1;
		for mapId = 1:nmap
            currfeat{mapId} = MaxGetSpatialPyramid(responsemap{mapId}, nlevel); 
            %currfeat会得到一个21列的vector，为啥呢？因为1+4+16=21
            if (max(currfeat{mapId})>0); flag=1; end
            
        end   %这边用的是OB-Max方法？%response map应该是包含了多种精度?(scale)nmap个
		featList{l} = vertcat(currfeat{:});  %feature结果，垂直连接；nmap种不同scale下的OB-Max结果，12个21*1的列向量；
        
        if (flag==1)
          for mapId=1:nmap
            detectoutpath=[num2str(detectorlist{l}),'/'];
            
             mkdir(detectoutpath); 
           
            
            filename=[detectoutpath,'Detector_',num2str(detectorlist{l}),'_Map_',num2str(mapId),'.jpg'];
            tmp=responsemap{mapId};
           
            figure('visible','off');
            pcolor(tmp);
            saveas_center(gcf,filename,imgSize(1,1),imgSize(1,2));
           % pause;
          end
        end
	
    end
	feat = vertcat(featList{:});  %最后全部拉成一个vector:44604=177*12*21

	fid = fopen([outputpath '-feat.txt'], 'w');
	fprintf(fid, '%f\n', feat);
	fclose(fid);

	if savermap==1, save([outputpath '-rmap.mat'], 'responsemap'); end
end

function []=saveas_center(h, save_file, width, height)
% saveas_center(h, save_file, width, height)

set(0,'CurrentFigure',h);

set(gcf,'PaperPositionMode','auto');
set(gca,'position',[0,0,1,1]);
set(gcf,'position',[1,1,width,height]);

saveas(h, save_file);
end

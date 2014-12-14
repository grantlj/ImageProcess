function getfeat_single_image(imagepath, outputfilename, outputpath, savermap)
	%���ûʲô��Ԥ���������
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
    savermap=1;            %����responseͼ;
	modelpath = 'Model/';
    
    %Ԥ�������������

	detectorlist = detectorset();      %�������
    L = length(detectorlist);          %�����������
	nlevel = 3; %nlevel�������Ǽ���spatial pyramid
    dim = 44604; interval=10; 
    nmap = 12; %nmap����ɶ���������ܹؼ�����scales�йأ���������12�ֲ�ͬ�ķֱ���
    Level=(interval+1):5:(interval+30); %level����ʲô���߰���ģ�

	im = imread(imagepath); %im = resize_img(im, 400);   %ͳһ������С��
    imgSize=size(im);
	[feat_py, scales] = featpyramid(im, 8, 10);         %resolution?
    %�����������İ�һ��ͼƬ�ֳɶ��pyramid size of hog=8(sbin);interval is the number of scales in an octave of the pyramid.

	for l=1:L
		load([modelpath, num2str(detectorlist{l}), '_final.mat']);
        disp(num2str(detectorlist{l}));
		[bbox responsemap] = detect_with_responsemap(Level, feat_py, scales, im, model, model.thresh);  %������������������responsemap��bounding box
		
%         if (size(bbox,2)>0 & max(bbox(end))>0) 
%             disp([num2str(detectorlist{l}),'HighLight!!!']);
%             pause;
%         end
        
        currfeat = cell(1,nmap);   %��ǰfeature�Ľ��;
        
        flag=-1;
		for mapId = 1:nmap
            currfeat{mapId} = MaxGetSpatialPyramid(responsemap{mapId}, nlevel); 
            %currfeat��õ�һ��21�е�vector��Ϊɶ�أ���Ϊ1+4+16=21
            if (max(currfeat{mapId})>0); flag=1; end
            
        end   %����õ���OB-Max������%response mapӦ���ǰ����˶��־���?(scale)nmap��
		featList{l} = vertcat(currfeat{:});  %feature�������ֱ���ӣ�nmap�ֲ�ͬscale�µ�OB-Max�����12��21*1����������
        
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
	feat = vertcat(featList{:});  %���ȫ������һ��vector:44604=177*12*21

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

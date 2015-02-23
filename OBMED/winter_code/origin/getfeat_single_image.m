function [feat]=getfeat_single_image(im)
	%���ûʲô��Ԥ���������
    addpath(genpath('code'));
	
    
	modelpath = 'Model/';
    
    %Ԥ�������������

	detectorlist = detectorset();      %�������
    L = length(detectorlist);          %�����������
	nlevel = 3; %nlevel�������Ǽ���spatial pyramid
    dim = 44604; interval=10; 
    nmap = 12; %nmap����ɶ���������ܹؼ�����scales�йأ���������12�ֲ�ͬ�ķֱ���
    Level=(interval+1):5:(interval+30); %level����ʲô���߰���ģ�

	
    im = resize_img(im, 400);   %ͳһ������С��
    imgSize=size(im);
	[feat_py, scales] = featpyramid(im, 8, 10);         %resolution?
    %�����������İ�һ��ͼƬ�ֳɶ��pyramid size of hog=8(sbin);interval is the number of scales in an octave of the pyramid.

	for l=1:L
		load([modelpath, num2str(detectorlist{l}), '_hard.mat']);
      %  disp(num2str(detectorlist{l}));
		[responsemap] = detect_with_responsemap(Level, feat_py, scales, im, model, model.thresh);  %������������������responsemap��bounding box
		
        currfeat = cell(1,nmap);   %��ǰfeature�Ľ��;
        
        flag=-1;
		for mapId = 1:nmap
            currfeat{mapId} = MaxGetSpatialPyramid(responsemap{mapId}, nlevel); 
            %currfeat��õ�һ��21�е�vector��Ϊɶ�أ���Ϊ1+4+16=21
            if (max(currfeat{mapId})>0); flag=1; end
            
        end   %����õ���OB-Max������%response mapӦ���ǰ����˶��־���?(scale)nmap��
		featList{l} = vertcat(currfeat{:});  %feature�������ֱ���ӣ�nmap�ֲ�ͬscale�µ�OB-Max�����12��21*1����������
        if (flag==1)
            disp(['***Interesting on object;',num2str(detectorlist{l})]);
        end
%         if (flag==1)
%           for mapId=1:nmap
%             detectoutpath=[num2str(detectorlist{l}),'/'];
%             
%              mkdir(detectoutpath); 
%            
%             
%             filename=[detectoutpath,'Detector_',num2str(detectorlist{l}),'_Map_',num2str(mapId),'.jpg'];
%             tmp=responsemap{mapId};
%            
%             figure('visible','off');
%             pcolor(tmp);
%             saveas_center(gcf,filename,imgSize(1,1),imgSize(1,2));
%            % pause;
%           end
%         end
	
    end
	feat = vertcat(featList{:});  %���ȫ������һ��vector:44604=177*12*21
    feat=feat';
% 	fid = fopen([outputpath '-feat.txt'], 'w');
% 	fprintf(fid, '%f\n', feat);
% 	fclose(fid);
% 
% 	if savermap==1, save([outputpath '-rmap.mat'], 'responsemap'); end
end



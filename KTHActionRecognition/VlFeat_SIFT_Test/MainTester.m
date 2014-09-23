function [] = MainTester()
    vl_setup;
    destFile='person16_jogging_d2_uncomp.avi';

    obj=VideoReader(destFile);  %�õ�����һ��object
    vidFrames=read(obj);     %�õ���������֡������
    numFrames=obj.numberOfFrames;  %����֡������

    for i=1:numFrames
      binSize = 10 ;
      magnif = 3 ;
      mov(i).cdata=vidFrames(:,:,:,i);                                %��ÿһ֡������
      mov(i).cdata=rgb2gray(mov(i).cdata);                            %ת���ɻҶ�
    %  mov(i).cdata=histeq(mov(i).cdata);
      figure('visible','off');
      imshow(mov(i).cdata);
      hold on;
      mov(i).cdata=single(mov(i).cdata);  
      mov(i).cdata= vl_imsmooth(mov(i).cdata, sqrt((binSize/magnif)^2 - .25));
      [f,d]=vl_sift(mov(i).cdata);   %�õ�SIFT��Ϣ
      h1 = vl_plotframe(f(:,1:size(f,2))) ;
      set(h1,'color','y','linewidth',1) ;
      saveas_center(gcf,[num2str(i),'.jpg'],160,120);
    end
    
function []=saveas_center(h, save_file, width, height)
% saveas_center(h, save_file, width, height)

set(0,'CurrentFigure',h);

set(gcf,'PaperPositionMode','auto');
set(gca,'position',[0,0,1,1]);
set(gcf,'position',[1,1,width,height]);

saveas(h, save_file);
end
    

end


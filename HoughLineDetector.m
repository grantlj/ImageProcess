function []=HoughLineDetector(filename)
  l_origin=imread(filename);
  l_gray=rgb2gray(l_origin);
  l_gray=medfilt2(l_gray,[2,2]);               %��ֵ�˲��������
  l_gray=im2bw(l_gray,graythresh(l_gray));     %ת��Ϊ��ֵͼ��
  l_gray=imopen(l_gray,strel('diamond',4));    %ʹ�������������� ��һ���ֻ�ֱ��
 
  figure;
  imshow(l_gray);
  
  figure;
  [H,T,R]=hough(l_gray);                       %hough�任 
  
  
   P=houghpeaks(H,5,'threshold',0.6*max(H(:))); %houghpeak���ҷ�ֵ���˴���5������ Ĭ��60%�ĵ����������ֱ��
   imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');   %��ʾhough�任���
   xlabel('\theta'), ylabel('\rho');
   axis on, axis normal, hold on;
   plot(T(P(:,2)),R(P(:,1)),'s','color','red');                      %��5��������������
   
   %��5���߱����
   lines = houghlines(l_gray,T,R,P,'FillGap',5,'MinLength',7);
   figure;
   imshow(l_origin);hold on;
   
    for k = 1:length(lines)
        %xy����ʼ�����ֹ��ļ���
         xy = [lines(k).point1; lines(k).point2];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');   %������֮������
 
         % plot beginnings and ends of lines
         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end;
end
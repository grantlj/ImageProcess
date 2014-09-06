function []=FaceDetectionTest()
   COEFFMatDir='D:\Matlab\MITFace\COEFF.dat';  %��COFF����
   meanFaceDir='D:\Matlab\MitFace\meanFace.dat';%�洢ƽ����
   SVMStructDir='D:\Matlab\Mitface\SVMStruct.mat';       %�洢SVM�����������Ϣ
   SVMStruct=load(SVMStructDir);
   %load(SVMStructDir,'SVMStruct');
   COEFF=load(COEFFMatDir);
   meanFace=load(meanFaceDir);
   clc;
   scoreTerm=70;                     %SVMʹ��PCA���ǰ70������
  path='D:\Matlab\Faces'; 
  path2='D:\Matlab\Faces\Detected2';
  
  t = cd(path);                        % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);   % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};DstFile={};
  for i= 3:n                           % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}         %  ���ȡ���ļ���
     if (findstr(name,'.jpg')>=1)
        filename=[t,'\',name]        %   ����ļ���
        fileInfo=[fileInfo;filename];
        filename2=[path2,'\',name];
        DstFile=[DstFile;filename2];
     end
  end
  
  phoCount=size(fileInfo,1);
  clc;
  
  for p=1:phoCount
      disp(fileInfo{p});
  l_origin=imread(fileInfo{p});
  l_origin=imresize(l_origin,[160,120]);
  l_gray=rgb2gray(l_origin);
  l_gray=histeq(l_gray);

  window_h=80;window_w=60;
  step_row=10;step_col=5;
  
 
   figure('visible','off');
   imshow(l_origin);
 
  for i=1:(160-window_h)/step_row+1;
      for j=1:(120-window_w)/step_col+1;
        
          % subplot(round((160-window_h)/step_row+1),round((120-window_w)/step_col+1),round((i-1)*((160-window_h)/step_row+1)+j)); 
         %figure;
          %imshow(l_gray);
          %hold on;
          %rectangle('Position',[(i-1)*step_row+1,(j-1)*step_col+1,window_h,window_w]);
          l_selected=l_gray((i-1)*step_row+1:(i-1)*step_row+window_h, (j-1)*step_col+1:(j-1)*step_col+window_w);  %ѡȡ�ض�����
          
          l_selected=imresize(l_selected,[20,20]);
    
    % imshow(l_selected);
          l_selected_info=double(zeros(1,20*20));
          
          for k=1:20
              for l=1:20
                  l_selected_info(1,(k-1)*20+l)=l_selected(k,l);
              end
          end
          
          l_selected_info=l_selected_info-meanFace;
          
          l_selected_info=l_selected_info*COEFF;
          l_selected_info=l_selected_info(1:scoreTerm);
          
          ret=svmclassify(SVMStruct,l_selected_info);
         % disp(ret);
          if (ret~=-1)
            %figure;
            %imshow(l_selected);
            hold on;
            rectangle('Position',[(i-1)*step_row+1,(j-1)*step_col+1,window_w,window_h]);
          end
           
          
          
      end
  end
  
  saveas_center(gcf,DstFile{p},120,160);
  
  end
  
end

%���ֱ��淽��������������figure�����İױ�
function []=saveas_center(h, save_file, width, height)
% saveas_center(h, save_file, width, height)

set(0,'CurrentFigure',h);

set(gcf,'PaperPositionMode','auto');
set(gca,'position',[0,0,1,1]);
set(gcf,'position',[1,1,width,height]);

saveas(h, save_file);
end
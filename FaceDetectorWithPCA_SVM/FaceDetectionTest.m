function []=FaceDetectionTest()
   COEFFMatDir='D:\Matlab\MITFace\COEFF.dat';  %存COFF矩阵
   meanFaceDir='D:\Matlab\MitFace\meanFace.dat';%存储平均脸
   SVMStructDir='D:\Matlab\Mitface\SVMStruct.mat';       %存储SVM分类器相关信息
   SVMStruct=load(SVMStructDir);
   %load(SVMStructDir,'SVMStruct');
   COEFF=load(COEFFMatDir);
   meanFace=load(meanFaceDir);
   clc;
   scoreTerm=70;                     %SVM使用PCA后的前70个参数
  path='D:\Matlab\Faces'; 
  path2='D:\Matlab\Faces\Detected2';
  
  t = cd(path);                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);   % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};DstFile={};
  for i= 3:n                           % 从3开始。前两个属于系统内部。
     name = allnames{1,i}         %  逐次取出文件名
     if (findstr(name,'.jpg')>=1)
        filename=[t,'\',name]        %   组成文件名
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
          l_selected=l_gray((i-1)*step_row+1:(i-1)*step_row+window_h, (j-1)*step_col+1:(j-1)*step_col+window_w);  %选取特定区域
          
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

%这种保存方法可以明显消除figure产生的白边
function []=saveas_center(h, save_file, width, height)
% saveas_center(h, save_file, width, height)

set(0,'CurrentFigure',h);

set(gcf,'PaperPositionMode','auto');
set(gca,'position',[0,0,1,1]);
set(gcf,'position',[1,1,width,height]);

saveas(h, save_file);
end
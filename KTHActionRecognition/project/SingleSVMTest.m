%1v1 SVM分类测试

function []=SingleSVMTest()
  root=(GetPresentPath);
  box_path='D:\Matlab\ImageProcess\KTHActionRecognition\boxing\';
  box_type='boxing';
  han_path='D:\Matlab\ImageProcess\KTHActionRecognition\handclapping\';
  han_type='handclapping';
  
  jog_path='D:\Matlab\ImageProcess\KTHActionRecognition\jogging\';
  jog_type='jogging';
  
  run_path='D:\Matlab\ImageProcess\KTHActionRecognition\running\';
  run_type='running';
  
  wal_path='D:\Matlab\ImageProcess\KTHActionRecognition\walking\';
  wal_type='walking';
  
  set1_path=box_path;set1_type=box_type;
  set2_path=han_path;set2_type=han_type;
  
% mean1=load([set1_path,set1_type,'_Mean.mat']);
% mean2=load([set2_path,set2_type,'_Mean.mat']);
  
  SVMFile=[set1_type,'_',set2_type,'_SVMStruct.mat'];
  SVMStruct=load(SVMFile);
   
  accuracy1=GetAccuracy(SVMStruct,set1_path,root,1);
  accuracy2=GetAccuracy(SVMStruct,set2_path,root,-1);
  
  disp(['Accuracy Set 1:',num2str(accuracy1)]);
  disp(['Accuracy Set 2:',num2str(accuracy2)]);
end

function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
i=findstr(p1,'\');
p1=p1(1:i(end));
res=p1;
end
 
%返回测试结果
function [accuracy]=GetAccuracy(SVMStruct,set_path,root,standardAns)
  accuracy=0;
  disp(set_path);
  t = cd(set_path);                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
  allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
  [m,n] = size(allnames);
  fileInfo={};
  for i= 3:n                           % 从3开始。前两个属于系统内部。
     name = allnames{1,i}         %  逐次取出文件名
     if ( (findstr(name,'.avi')>=1) & (findstr(name,'d4')>=1) )
        filename=[set_path,name]        %   组成文件名
        fileInfo=[fileInfo;filename];
     end
  end
  
  aviCount=size(fileInfo,1);
  clc;
  t=cd(root);
  clc;
  
  for p=1:aviCount
     nowFile=fileInfo{aviCount-p+1};              %我们从末尾向头测试，因为最前面的若干是训练集
   %  nowFile=fileInfo{p};
      %ret=svmclassify(SVMStruct,l_selected_info);
      MotionHistoryImageInfo=GetMotionHistoryInfo(nowFile);
      raw=[];
        disp('   Generating Hu-Moments');
      for k=1:MotionHistoryImageInfo.retFrameCount
          [m20,m02,m12,m21,m22,m30,m03]=GetHuMomentInfo(MotionHistoryImageInfo.image(:,:,k));
          raw=[raw,m20,m02,m12,m21,m22,m30,m03];
      end
        disp('   Finished Hu-Moments');
      raw=double(raw);
      ret=svmclassify(SVMStruct,raw);
      if (ret==standardAns)
          accuracy=accuracy+1;
          disp([nowFile,': Right']);
      else
          disp([nowFile,': Wrong']);
      end
  end
  
  accuracy=double(accuracy)/aviCount;

end
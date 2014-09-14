%1v1 SVM�������

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
 
%���ز��Խ��
function [accuracy]=GetAccuracy(SVMStruct,set_path,root,standardAns)
  accuracy=0;
  disp(set_path);
  t = cd(set_path);                        % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  for i= 3:n                           % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}         %  ���ȡ���ļ���
     if ( (findstr(name,'.avi')>=1) & (findstr(name,'d4')>=1) )
        filename=[set_path,name]        %   ����ļ���
        fileInfo=[fileInfo;filename];
     end
  end
  
  aviCount=size(fileInfo,1);
  clc;
  t=cd(root);
  clc;
  
  for p=1:aviCount
     nowFile=fileInfo{aviCount-p+1};              %���Ǵ�ĩβ��ͷ���ԣ���Ϊ��ǰ���������ѵ����
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
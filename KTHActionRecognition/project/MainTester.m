function [] = MainTester()
   root=(GetPresentPath);
   test_path='D:\Matlab\ImageProcess\KTHActionRecognition\boxing\';
   test_type='boxing';
   
   %pathes={'D:\Matlab\ImageProcess\KTHActionRecognition\boxing\','D:\Matlab\ImageProcess\KTHActionRecognition\handclapping\','D:\Matlab\ImageProcess\KTHActionRecognition\jogging\','D:\Matlab\ImageProcess\KTHActionRecognition\running\','D:\Matlab\ImageProcess\KTHActionRecognition\walking\'};
   types={'boxing','handclapping','jogging','running','walking'};
   
  t = cd(test_path);                        % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  for i= 3:n                           % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}         %  ���ȡ���ļ���
     if ( (findstr(name,'.avi')>=1) & (findstr(name,'d4')>=1) )
        filename=[test_path,name]        %   ����ļ���
        fileInfo=[fileInfo;filename];
     end
  end
  
  aviCount=size(fileInfo,1);
  clc;
  t=cd(root);
  clc;
  
  rightCount=0;
  for p=1:aviCount
     nowFile=fileInfo{aviCount-p+1};
      MotionHistoryImageInfo=GetMotionHistoryInfo(nowFile);
      raw=[];
        disp('   Generating Hu-Moments');
      for k=1:MotionHistoryImageInfo.retFrameCount
          [m20,m02,m12,m21,m22,m30,m03]=GetHuMomentInfo(MotionHistoryImageInfo.image(:,:,k));
          raw=[raw,m20,m02,m12,m21,m22,m30,m03];
      end
        disp('   Finished Hu-Moments');
      raw=double(raw);
      count=0;
        for i=1:size(types,2)-1
           for j=i+1:size(types,2)
              
               if (strcmp(types{i},test_type) || strcmp(types{j},test_type))
                  if (strcmp(types{i},test_type))
                    std=1;
                  else
                    std=-1;    
                  end    
                  SVMFile=[types{i},'_',types{j},'_SVMStruct.mat'];
                  SVMStruct=load(SVMFile);
                  ret=svmclassify(SVMStruct,raw);
                  if (ret==std)
                      count=count+1;
                  end
               end
              
               %disp(SVMDir);
           end
        end %end of i j
        
        if (2*count>=size(types,2))
            disp([]);
            disp([nowFile,' is CORRECTLY classified:)']);
            rightCount=rightCount+1;
        else
            disp([]);
            disp([nowFile,' is incorrectly classified:(']);
        end
    
  end %end of p
  disp([]);
  disp(['Overall Rate is:',num2str(rightCount*100/aviCount)]);
end

function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
i=findstr(p1,'\');
p1=p1(1:i(end));
res=p1;
end
 


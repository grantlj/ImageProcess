
%生成某一特定文件夹（动作类型）训练集（前9个人的各种场景）下的原始数据
function [] = GeneateFundamentalInfo(path)
  
  trainCount=9;
  
% path='D:\Matlab\ImageProcess\KTHActionRecognition\boxing\';
% type='boxing';
  %path='D:\Matlab\ImageProcess\KTHActionRecognition\handclapping\';
 % type='handclapping';
%   
  %path='D:\Matlab\ImageProcess\KTHActionRecognition\jogging\';
 % type='jogging';
%   
  %path='D:\Matlab\ImageProcess\KTHActionRecognition\running\';
  % type='running';
%   
 path='D:\Matlab\ImageProcess\KTHActionRecognition\walking\';
 type='walking';
  
 dbName=[path,type,'_RawData_Training.mat'];
 dbraw=[];
  for i=1:trainCount
      for j=4:4
         filename=[path,'person0',num2str(i),'_',type,'_d',num2str(j),'_uncomp.avi'];
         try
         MotionHistoryImageInfo=GetMotionHistoryInfo(filename);
         raw=[];
         disp('   Generating Hu-Moments');
         for k=1:MotionHistoryImageInfo.retFrameCount
          [m20,m02,m12,m21,m22,m30,m03]=GetHuMomentInfo(MotionHistoryImageInfo.image(:,:,k));
           raw=[raw,m20,m02,m12,m21,m22,m30,m03];
         end
         disp([filename,' finished...']);
         dbraw=[dbraw;raw];
          disp('   Finished Hu-Moments');
         catch
             disp(['Error at: ',filename]);
         end
      end
             
  end
  
 % t=cd('..');
  save(dbName,'dbraw');
  
end


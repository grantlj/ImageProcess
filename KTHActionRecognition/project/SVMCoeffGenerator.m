%生成1v1 SVM 系数（根据FundamentalInfo）
function [] = SVMCoeffGenerator()
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
  
  %set1_path=box_path;set1_type=box_type;
  %set2_path=han_path;set2_type=han_type;
  set1_path=run_path;set1_type=run_type;
  set2_path=wal_path;set2_type=wal_type;
  %boxing_RawData_Training.mat
  
  file1=[set1_path,set1_type,'_RawData_Training.mat'];
  data1=load(file1);
  size1=size(data1.dbraw,1);
  
  file2=[set2_path,set2_type,'_RawData_Training.mat'];
  data2=load(file2);size2=size(data2.dbraw,1);
  
  retFile=[set1_type,'_',set2_type,'_SVMStruct.mat'];
  
%   meanv=double(mean(data1.dbraw));
%  % data1.dbraw=double(data1.dbraw)-double(mean1.*ones(size(data1.dbraw)));
%  for i=1:size1
%      data1.dbraw(i,:)=double(data1.dbraw(i,:))-meanv;
%  end
%   save([set1_path,set1_type,'_Mean.mat'],'meanv');
%   meanv=double(mean(data2.dbraw));
%  % data2.dbraw=double(data2.dbraw)-double(mean2.*ones(size(data2.dbraw)));
%   for i=1:size2
%      data2.dbraw(i,:)=double(data2.dbraw(i,:))-meanv;
%   end

%   save([set2_path,set2_type,'_Mean.mat'],'meanv');
  
  TrainingSet=double([data1.dbraw;data2.dbraw]);
  Tag=zeros(size1+size2,1);
  
  for i=1:size1
      Tag(i)=1;
  end
  for i=size1+1:size1+size2
      Tag(i)=-1;
  end
  
  SVMStruct=svmtrain(TrainingSet,Tag,'Kernel_Function','linear','showplot',true);
  disp(['SVM Coeefficent generated between: ',set1_type,' and ',set2_type]);
  save(retFile,'-struct','SVMStruct');
  
end


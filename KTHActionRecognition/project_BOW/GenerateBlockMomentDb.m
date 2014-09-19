%����ĳһ�ض����������µ�����avi��MomentInfo
function [] = GenerateBlockMomentDb()
  %�ļ��к�����ѡ�����Ӧ��ע�ͣ����ɶ�Ӧ�ļ����µ�ѵ��������
  root=(GetPresentPath);
  
    % path='D:\Matlab\ImageProcess\KTHActionRecognition\boxing\'; 
    % type='boxing';
    % path='D:\Matlab\ImageProcess\KTHActionRecognition\handclapping\';
    % type='handclapping';   
    % path='D:\Matlab\ImageProcess\KTHActionRecognition\jogging\';
    % type='jogging';   
    % path='D:\Matlab\ImageProcess\KTHActionRecognition\running\';
    % type='running';   
     %path='D:\Matlab\ImageProcess\KTHActionRecognition\walking\';
    % type='walking';
    
%    path='boxing/'; 
%     type='boxing';
   %path='handclapping/';
%     type='handclapping';   
%   path='jogging/';
%     type='jogging';   
%     path='\running\';
%     type='running';   
     path='walking/';
   % type='walking';
    
    
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  hufileInfo={};
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'.avi')>=1))
        filename=[name];                   %   ����ļ���
        fileInfo=[fileInfo;filename];
        hufileInfo=[hufileInfo;strrep(filename,'.avi','_HU.mat')];
     end
  end
  
  aviCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  for i=1:aviCount
    disp(['******File:',fileInfo{i}]);
    
    if (~exist([path,hufileInfo{i}],'file'))
        disp('      Generating Block Moment info...');
        SaveBlockMomentInfo(path,fileInfo{i},hufileInfo{i});
        disp('   ');
    else
        disp('      Block Moment Info already existed...');
    end
    
  end
  

end


function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
disp(p1);
i=findstr(p1,'/');
if (isempty(i))         %Differ between Linux and Win
    i=findstr(p1,'\');
end
disp(i);
p1=p1(1:i(end));
res=p1;
end
 

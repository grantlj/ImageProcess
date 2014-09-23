%�����ض��ļ����������ļ���SIFT Info
function [] = GenerateSIFTRawDb()
   %�ļ��к�����ѡ�����Ӧ��ע�ͣ����ɶ�Ӧ�ļ����µ�ѵ��������
  root=(GetPresentPath);
 path='boxing/'; 
 %path='handclapping/';
 %path='jogging/';
 %path='running/';  
 %path='walking/';
 
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  fileInfo={};
  
  siftfileInfo={};
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     if ( (findstr(name,'.avi')>=1))
        filename=[path,name];                   %   ����ļ���
        fileInfo=[fileInfo;filename];
        siftfileInfo=[siftfileInfo;strrep(filename,'.avi','_SIFT.mat')];
     end
  end
  
  aviCount=size(fileInfo,1);
  t=cd(root);
  clc;
  
  for i=1:aviCount
      disp(['******File:',fileInfo{i}]);
    
    if (~exist([path,siftfileInfo{i}],'file'))
        disp('      Generating SIFT-RAW...');
        ret=GenerateSiftRawInfo(fileInfo{i});
        save(siftfileInfo{i},'ret');
        disp('   ');
    else
        disp('      SIFT-RAW already existed...');
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

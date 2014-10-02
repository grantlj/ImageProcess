%����K-means������������ÿ��avi��bag-of-words��hist��Ϣ
function [] = GenerateHistDb()
   %�ļ��к�����ѡ�����Ӧ��ע�ͣ����ɶ�Ӧ�ļ����µ�ѵ��������
  root=(GetPresentPath);
  paths={'boxing/','handclapping/','jogging/','running/','walking/'};
  
  for pathi=1:size(paths,2)
      path=paths{pathi};
      t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
      allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
      [m,n] = size(allnames);
      fileInfo={};
      histfileInfo={};
      for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
         name = allnames{1,i}                  %  ���ȡ���ļ���
         if ( (findstr(name,'_TRA.mat')>=1))
            filename=[name];                   %   ����ļ���
            fileInfo=[fileInfo;filename];
            histfileInfo=[histfileInfo;strrep(filename,'_TRA.mat','_HIST.mat')];
         end
      end

      aviCount=size(fileInfo,1);
      t=cd(root);
      clc;

      for i=1:aviCount
        disp(['******File:',fileInfo{i}]);

        if (~exist([path,histfileInfo{i}],'file'))
            disp('      Generating Hist info...');
            GenerateSingleFileHist(path,fileInfo{i},histfileInfo{i});
            disp('   ');
        else
            disp('      Hist Info already existed...');
        end

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


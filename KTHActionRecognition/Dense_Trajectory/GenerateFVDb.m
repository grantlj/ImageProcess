%����GMM������������������Ƶ��Fisher Vector
function [] = GenerateFVDb()
  vl_setup;
  root=(GetPresentPath);
  classInfoPath='FV_ClassInfo.mat';
  load(classInfoPath);
  
  means=ClassInfo.means;covariances=ClassInfo.covariances;priors=ClassInfo.priors;
  
  paths={'boxing/','handclapping/','jogging/','running/','walking/'};
  for pathi=1:size(paths,2)
      path=paths{pathi};
      t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
      allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
      [m,n] = size(allnames);
      fileInfo={};
      fvfileInfo={};
      for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
         name = allnames{1,i}                  %  ���ȡ���ļ���
         if ( (findstr(name,'_MBH.mat')>=1))
            filename=[name];                   %   ����ļ���
            fileInfo=[fileInfo;filename];
            fvfileInfo=[fvfileInfo;strrep(filename,'_MBH.mat','_FV.mat')];
         end
      end

      aviCount=size(fileInfo,1);
      t=cd(root);
      clc;

      for i=1:aviCount
        disp(['******File:',fileInfo{i}]);

        if (~exist([path,fvfileInfo{i}],'file'))
            disp('      Generating Fisher Vector info...');
            GenerateSingleFileFV(path,fileInfo{i},fvfileInfo{i},means,covariances,priors);
            disp('   ');
        else
            disp('      Fisher Vector Info already existed...');
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

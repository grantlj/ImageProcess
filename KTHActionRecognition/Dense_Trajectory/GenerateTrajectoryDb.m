function [] = GenerateTrajectoryDb()
% ������
% 1. ����һ��Ŀ¼������video
% 2. ��ÿһ��video resize��8�ֳ߶�
% 3. ��2�ķ��ؽ�������������
% 4. ����trajectory
% 5. ������trajectory���ϣ����浽�ļ���

    root=(GetPresentPath);
    paths={'boxing/','handclapping/','jogging/','running/','walking/'};
    for pathCount=1:size(paths,2)
        
        path=paths{pathCount};
        t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
        allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
        [m,n] = size(allnames);
        fileInfo={};
        
        trafileInfo={};
        
         for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
            name = allnames{1,i}                  %  ���ȡ���ļ���
            if ( (findstr(name,'.avi')>=1))
                filename=[path,name];                   %   ����ļ���
                fileInfo=[fileInfo;filename];
                trafileInfo=[trafileInfo;strrep(filename,'.avi','_TRA.mat')];
            end
         end
         
         aviCount=size(fileInfo,1);
         t=cd(root);
         clc;
         
         for i=1:aviCount   %��ʽ��ȡ���̿�ʼ
               disp(['******File:',fileInfo{i}]);
    
                if (~exist([trafileInfo{i}],'file'))
                    disp('      Generating TRA-RAW...');
                    ret=GenerateTRARawInfo(fileInfo{i});
                    save(trafileInfo{i},'ret');
                    disp('   ');
                else
                    disp('      TRA-RAW already existed...');
                end
         end  %end of i     
    end  %end of pathCount

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


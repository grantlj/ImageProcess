function [] = GenerateTrajectoryDb()
% 主程序：
% 1. 读入一个目录下所有video
% 2. 对每一个video resize成8种尺度
% 3. 将2的返回结果用来计算光流
% 4. 请求trajectory
% 5. 将所有trajectory联合，保存到文件中

    root=(GetPresentPath);
    paths={'boxing/','handclapping/','jogging/','running/','walking/'};
    for pathCount=1:size(paths,2)
        
        path=paths{pathCount};
        t = cd(path);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
        allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
        [m,n] = size(allnames);
        fileInfo={};
        
        trafileInfo={};
        
         for i= 3:n                               % 从3开始。前两个属于系统内部。
            name = allnames{1,i}                  %  逐次取出文件名
            if ( (findstr(name,'.avi')>=1))
                filename=[path,name];                   %   组成文件名
                fileInfo=[fileInfo;filename];
                trafileInfo=[trafileInfo;strrep(filename,'.avi','_TRA.mat')];
            end
         end
         
         aviCount=size(fileInfo,1);
         t=cd(root);
         clc;
         
         for i=1:aviCount   %正式提取过程开始
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


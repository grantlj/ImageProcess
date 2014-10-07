%Fisher Vector下全场景测试
% 
% Final Result:
% boxing/:87.8788%
% handclapping/:84.8485%
% jogging/:88%
% running/:96%
% walking/:93%

%单一场景测试：全部100%
% 主测试程序
function [] = MainTester()
testpaths={'boxing/','handclapping/','jogging/','running/','walking/'};
root=(GetPresentPath);
load('SVMModel.mat');
accuracy=zeros(1,size(testpaths,2));

for tester=1:size(testpaths,2)
    
    testpath=testpaths{tester};
    
    disp(['Test set:', testpath]);
    
    t = cd(testpath);                            % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件
    allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
    [m,n] = size(allnames);
    fvfileInfo={};
    for i= 3:n                               % 从3开始。前两个属于系统内部。
        name = allnames{1,i}                  %  逐次取出文件名
        if ( (findstr(name,'_FV.mat')>=1))
        %if ( (findstr(name,'_FV.mat')>=1) & findstr(name,'d4')>=1)
            filename=[testpath,name];                   %   组成文件名
            fvfileInfo=[fvfileInfo;filename];
            
        end
    end
    
    
    fvCount=size(fvfileInfo,1);
    t=cd(root);
    clc;
    tag=double(zeros(1,fvCount));
    fvs=[];
    for i=1:fvCount
        file=fvfileInfo{i};
        if (strfind(file,'boxing')) tag(i)=1; end
        if (strfind(file,'handclapping')) tag(i)=2; end
        if (strfind(file,'jogging')) tag(i)=3;end
        if (strfind(file,'running')) tag(i)=4;end
        if (strfind(file,'walking')) tag(i)=5;end
        load(fvfileInfo{i});
        %        maxVal=max(fvVal);minVal=min(fvVal);
        %       fvVal=(fvVal-minVal)./(maxVal-minVal);
        fvs=[fvs;fvVal'];
    end
    tag=tag';
    [~, accur, ~]=svmpredict(tag,fvs,model);
    accuracy(1,tester)=accur(1);
end
clc;
disp('Final Result:');
for i=1:size(testpaths,2)
    disp([testpaths{i},':',num2str(accuracy(1,i)),'%']);
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
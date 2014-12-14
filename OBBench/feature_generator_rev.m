function []=feature_generator_rev()
 
  datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'};
  root=(GetPresentPath);
  for datacount=1:size(datapath,2)
      db=datapath{size(datapath,2)-datacount+1};
      t=cd(db);
      clc;
      delete('*.tform.mat');
      allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
      [m,n] = size(allnames);
      videoInfo={};
      for i= 1:n                               % 从3开始。前两个属于系统内部。
        name = allnames{1,i}                  %  逐次取出文件名
       % disp(name);
        %disp(num2str(strfind(name,'.mat')));
         if ( (findstr(name,'.avi')>=1) & (isempty(findstr(name,'-Feature.mat'))))
           % disp(num2str(strfind(name,'.mat')));
          %  disp(name);
            videoname=[db,name];                   %   组成文件名
            videoInfo=[videoInfo;videoname];
          end
      end
    
    videoCount=size(videoInfo,1);
    t=cd(root);
    clc;
    for i=1:videoCount
      %disp(videoInfo{i});
      if (~exist([videoInfo{i},'-Feature.mat'],'file'))
       getfeat_single_video(videoInfo{i});
      
      else
          disp(['Skipppp...']);
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
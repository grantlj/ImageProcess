function []=feature_generator_rev()
 
  datapath={'dataset/pick/','dataset/run/','dataset/throw/','dataset/walk/','dataset/wave/'};
  root=(GetPresentPath);
  for datacount=1:size(datapath,2)
      db=datapath{size(datapath,2)-datacount+1};
      t=cd(db);
      clc;
      delete('*.tform.mat');
      allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
      [m,n] = size(allnames);
      videoInfo={};
      for i= 1:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
        name = allnames{1,i}                  %  ���ȡ���ļ���
       % disp(name);
        %disp(num2str(strfind(name,'.mat')));
         if ( (findstr(name,'.avi')>=1) & (isempty(findstr(name,'-Feature.mat'))))
           % disp(num2str(strfind(name,'.mat')));
          %  disp(name);
            videoname=[db,name];                   %   ����ļ���
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
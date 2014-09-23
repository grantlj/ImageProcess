function [] = GeneratorSVMInfo()
  path='histRAW\';
  root=(GetPresentPath);
  SVMModel='SVMModel.mat';
  
  t = cd(path);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
  allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
  [m,n] = size(allnames);
  histfileInfo={};
  for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
     name = allnames{1,i}                  %  ���ȡ���ļ���
     %if ( (findstr(name,'_HIST.mat')>=1) )
        if ( (findstr(name,'_HIST.mat')>=1) & (findstr(name,'d4')>=1))
        filename=[path,name];                   %   ����ļ���
        histfileInfo=[histfileInfo;filename];
       
     end
  end
  
  histCount=size(histfileInfo,1);
  t=cd(root);
  clc;
  
  tag=double(zeros(1,histCount));
  hists=[];
  for i=1:histCount
      file=histfileInfo{i};
      if (strfind(file,'boxing')) tag(i)=1; end
      if (strfind(file,'handclapping')) tag(i)=2; end
      if (strfind(file,'jogging')) tag(i)=3;end
      if (strfind(file,'running')) tag(i)=4;end
      if (strfind(file,'walking')) tag(i)=5;end    
      load(histfileInfo{i});
      maxVal=max(histVal);minVal=min(histVal);
      histVal=(histVal-minVal)./(maxVal-minVal);
      hists=[hists;histVal];
  end
  tag=tag';
  
  %���񷨲���Ѱ��
  
% [bestCVaccuracy,bestc,bestg]=SVMcgForClass(tag,hists,-9,9,-9,9,size(tag,1),1,1,6);
%�������ź� c=4 g=4
 model=svmtrain(tag,hists,'-s 1 -t 2 -g 4');  %V-svc
% model=svmtrain(tag,hists,'-s 1');  %V-svc

 save(SVMModel,'model');

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
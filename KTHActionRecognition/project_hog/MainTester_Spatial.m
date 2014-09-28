
% �����Գ���

%�������ź���Խ��
%boxing:           100%
%handclapping:     80%
%jogging:          80%
%running:          96%
%walking:          76%

function [] = MainTester_Spatial() 

  testpaths={'boxing/','handclapping/','jogging/','running/','walking/'};
  root=(GetPresentPath);
  load('SVMModel_Spatial.mat');
  accuracy=zeros(1,size(testpaths,2));
  
  for tester=1:size(testpaths,2)
      
          testpath=testpaths{tester};

          disp(['Test set:', testpath]);

          t = cd(testpath);                            % dos����cd���õ�ǰ·�����������ã����°���ȫ���������ļ�
          allnames = struct2cell(dir);             % dos����dir�г����е��ļ�����struct2cellת��ΪԪ������
          [m,n] = size(allnames);
          histfileInfo={};
          for i= 3:n                               % ��3��ʼ��ǰ��������ϵͳ�ڲ���
             name = allnames{1,i}                  %  ���ȡ���ļ���
             %if ( (findstr(name,'_HIST_SPATIAL.mat')>=1))
                 if ( (findstr(name,'_HIST_SPATIAL.mat')>=1) & findstr(name,'d4')>=1)
                filename=[testpath,name];                   %   ����ļ���
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
        %        maxVal=max(histVal);minVal=min(histVal);
        %       histVal=(histVal-minVal)./(maxVal-minVal);
              hists=[hists;histVal];
          end
          tag=tag';
          [~, accur, ~]=svmpredict(tag,hists,model); 
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
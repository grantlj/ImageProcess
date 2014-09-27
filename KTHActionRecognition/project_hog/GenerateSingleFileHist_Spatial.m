%�õ�ָ����Ƶ��һ��֮���bowֱ��ͼ,���뵽histfilenameָ�����ļ���
function [histVal] = GenerateSingleFileHist_Spatial(path,filename,histfilename)
%function [histVal] = GenerateSingleFileHist_Spatial()
%  filename='boxing\person02_boxing_d2_uncomp_HOG.mat';
   filename=[path,filename];
   histfilename=[path,histfilename];
  warning off all;
  load(filename);
  classInfoPath='ClassInfo.mat';
  load(classInfoPath);
  core=classInfo.C;
  
  [coreCount,dim]=size(core);
  histVal=[];
  frameCount=size(ret,2);
  
%   disp(['Frame count:',num2str(frameCount)]);
%   trunks=linspace(1,frameCount,3);
  
  disp('Calculating Raw Data...');
  histSingle=zeros(frameCount,coreCount);                       %��Ҫ��ÿһ֡��ͶƱ�����Ϊԭʼ���ݣ������ظ�����

  for i=1:frameCount
     fnow=ret{i};
   
      for j1=1:size(fnow,1)
         for j2=1:size(fnow,2)                        %Every hog in every block
           mindist=inf;minp=1;

               for k=1:coreCount
               % tmp=pdist2(core(k),[fnow(3,j),fnow(4,j)]);
                 tmp=0;
                 for dim=1:size(core,2)
                     tmp=tmp+(core(k,dim)-fnow(j1,j2,dim))^2;
                 end %end of dim

                 %disp(num2str(k));
                tmp=sqrt(tmp);

                if (tmp<mindist)
                    mindist=tmp;
                    minp=k;
                end

               end% end of k
              histSingle(i,minp)=histSingle(i,minp)+1;    %��ǰ�߶��µ�ͶƱ���
         end 
     end %end of j1,j2
       
  end
  
  disp('Finished Raw Data...');
    
 for level=1:3                                               %�ֳ�����level
    trunks=round(linspace(1,frameCount,level+1));
    
    for n=1:size(trunks,2)-1                          
         histTmp=zeros(1,coreCount);                        %��ͬά���µ���hist����������block��֡ƴ�Ӷ���
        for i=trunks(n):trunks(n+1)                         %Every frame
             histTmp=histTmp+histSingle(i);
        end%end of i
        
         maxVal=max(histTmp);minVal=min(histTmp);
         histTmp=(histTmp-minVal)./(maxVal-minVal);
         histVal=[histVal,histTmp];
    end%end of n
        
  disp(['Level:',num2str(level),' completed...']);   
 end%end of level
  

   % maxVal=max(histVal);minVal=min(histVal);
   % histVal=(histVal-minVal)./(maxVal-minVal);
  
    save(histfilename,'histVal');
    
   % bar(histVal);
      
end


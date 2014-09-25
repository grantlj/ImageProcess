%得到指定视频归一化之后的bow直方图,存入到histfilename指定的文件中
function [histVal] = GenerateSingleFileHist_Spatial(path,filename,histfilename)
%function [histVal] = GenerateSingleFileHist_Spatial()
%  filename='boxing\person02_boxing_d2_uncomp_SIFT.mat';
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
    
  for level=1:4                                   %分成四个level
    trunks=round(linspace(1,frameCount,level+1));
    
    for n=1:size(trunks,2)-1                          
         histTmp=zeros(1,coreCount);
        for i=trunks(n):trunks(n+1)                         %Every frame
             fnow=ret(i).f;
             for j=1:size(fnow,2)                     %Every sift in every frame
               mindist=inf;minp=1;

               for k=1:coreCount
               % tmp=pdist2(core(k),[fnow(3,j),fnow(4,j)]);
                tmp=sqrt((core(k,1)-fnow(3,j))^2+(core(k,2)-fnow(4,j))^2);
                if (tmp<mindist)
                    mindist=tmp;
                    minp=k;
                end

               end
              histTmp(minp)=histTmp(minp)+1;             %当前尺度下的投票结果
             end
        end
         maxVal=max(histTmp);minVal=min(histTmp);
         histTmp=(histTmp-minVal)./(maxVal-minVal);
         histVal=[histVal,histTmp];
    end
  
  end
  

   % maxVal=max(histVal);minVal=min(histVal);
   % histVal=(histVal-minVal)./(maxVal-minVal);
  
    save(histfilename,'histVal');
    
   % bar(histVal);
      
end


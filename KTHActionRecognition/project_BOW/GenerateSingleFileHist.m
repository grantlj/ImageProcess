%得到指定视频归一化之后的bow直方图
function [histVal] = GenerateSingleFileHist(filename)
  %filename='huRaw\person02_boxing_d2_uncomp_HU.mat';
  warning off all;
  load(filename);
  classInfoPath='ClassInfo.mat';
  load(classInfoPath);
  core=[];
  for i=1:size(classInfo.C,1)
      if (~isnan(classInfo.C(i)))
         core=[core;classInfo.C(i,:)]; 
      end
  end
  
  [coreCount,dim]=size(core);
  histVal=zeros(1,coreCount);
  vecCount=size(huMat,1);
  for i=1:vecCount
    mindist=inf;minp=1;
    for j=1:coreCount
        tmp=pdist2(core(j),huMat(i));
        if (tmp<mindist)
            mindist=tmp;
            minp=j;
        end
        
    end
    
    histVal(minp)=histVal(minp)+1;
  end
  

    maxVal=max(histVal);minVal=min(histVal);
    histVal=(histVal-minVal)./(maxVal-minVal);
  
  
  bar(histVal);
      
end


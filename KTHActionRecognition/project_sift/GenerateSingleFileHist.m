%得到指定视频归一化之后的bow直方图,存入到histfilename指定的文件中
function [histVal] = GenerateSingleFileHist(path,filename,histfilename)

 % filename='boxing\person02_boxing_d2_uncomp_SIFT.mat';
  filename=[path,filename];
  histfilename=[path,histfilename];
  warning off all;
  load(filename);
  classInfoPath='ClassInfo.mat';
  load(classInfoPath);
  core=classInfo.C;
%   for i=1:size(classInfo.C,1)
%       if (~isnan(classInfo.C(i)))
%          core=[core;classInfo.C(i,:)]; 
%       end
%   end
  
  [coreCount,dim]=size(core);
  histVal=zeros(1,coreCount);
  frameCount=size(ret,2);
  for i=1:frameCount                          %Every frame
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
      histVal(minp)=histVal(minp)+1;   
    end
    
  
  end
  

   % maxVal=max(histVal);minVal=min(histVal);
   % histVal=(histVal-minVal)./(maxVal-minVal);
  
    save(histfilename,'histVal');
    
   % bar(histVal);
      
end


%得到指定视频归一化之后的bow直方图,存入到histfilename指定的文件中
function [histVal] = GenerateSingleFileHist(path,filename,histfilename)

 
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
  vecCount=size(ret,1);
  
  for i=1:vecCount                          %Every frame
     vnow=ret(i,:);
     minVal=inf;minp=1;
     
     for k=1:coreCount
         tmp=0;
         for l=1:dim
             tmp=tmp+(core(k,l)-vnow(1,l))^2;
         end
         tmp=sqrt(tmp);
         if (tmp<minVal)
             minVal=tmp;minp=k;
         end
     end
     
      histVal(minp)=histVal(minp)+1;   
  end
  

    maxVal=max(histVal);minVal=min(histVal);
    histVal=(histVal-minVal)./(maxVal-minVal);
  
    save(histfilename,'histVal');
    
   % bar(histVal);
      
end


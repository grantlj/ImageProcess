%得到指定视频的Fisher Vector信息
function [fvVal] = GenerateSingleFileFV(path,filename,fvfilename,means,covariances,priors)
  vl_setup;
  filename=[path,filename];
  fvfilename=[path,fvfilename];
  warning off all;
  load(filename);
  frameCount=size(ret,2);
  fall=[];
  total=0;
  for i=1:frameCount                          %Every frame
     sgFrame=ret(i).f;
         for k=1:size(sgFrame,2)
             total=total+1;
             fall(total,1)=sgFrame(3,k);fall(total,2)=sgFrame(4,k);
         end
  end
  
  fvVal = vl_fisher(fall', means, covariances, priors);
  save(fvfilename,'fvVal');
    
      
end


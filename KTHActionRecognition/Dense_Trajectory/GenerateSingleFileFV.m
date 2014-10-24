%�õ�ָ����Ƶ��Fisher Vector��Ϣ
function [fvVal] = GenerateSingleFileFV(path,filename,fvfilename,means,covariances,priors)
  
  filename=[path,filename];
  fvfilename=[path,fvfilename];
  warning off all;
  load(filename);
  fall=double(ret);
  fvVal = vl_fisher(fall', means, covariances, priors);
  save(fvfilename,'fvVal');
end


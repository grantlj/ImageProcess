in_filename='D:\dataset\birds\set.mat';
out_filename='D:\dataset\birds\setid.mat';
load(in_filename);

trnid=[];
valid=[];
tstid=[];


for i=1:6033
  
  if (~ismember(i,set))
      tstid=[tstid,i];
  else
      trnid=[trnid,i];
  end
end

save(out_filename,'trnid','valid','tstid');

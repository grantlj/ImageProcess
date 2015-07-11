%pre-processing of Gao's feature.

detectorlist={};
model_path='Model/';

t=cd(model_path);
allnames=struct2cell(dir);
[m,n]=size(allnames);
total=0;
for i=3:n
    name=allnames{1,i};
    if ((findstr(name,'.mat')>=1))
       model_real_name=name(1:findstr(name,'_hard')-1);
       total=total+1;
       detectorlist{total}=model_real_name;
    end
end

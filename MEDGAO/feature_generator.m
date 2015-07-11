function [] = feature_generator(dev_evl)
  if (nargin<1); dev_evl=0;  end    %dev_evl=0 means training set.
                                    %dev_evl=1 means test set.
  
  switch(dev_evl)
      case 0
          dev_evl_path='dataset_MED/train/';
          mask_path='dataset_MED/dev/';
          idx_path='dataset_MED/training.idx';
      case 1
          dev_evl_path='dataset_MED/test/';
          mask_path='dataset_MED/evl/';
          idx_path='dataset_MED/evl.idx';
      otherwise
          error('invalid input parameter...');
  end
 
 if (~exist(dev_evl_path,'dir'))
     mkdir(dev_evl_path);
 end
 
 datapath='/data/gaocq/MED11_small_9746/dataset9746/';
 %datapath='D:/Matlab/ImageProcess/OBMED/';
 
  root=GetPresentPath();
  idxinfo=load_idxinfo(idx_path);
  
  action_classes=get_action_classes(mask_path);
  cd(root);clc;
  
  for i=1:size(action_classes,2)
    action=action_classes{i};
    mask=load_mask_fromfile([mask_path,action,'.label']);
    out_path=[dev_evl_path,action,'/'];  %feature output path;
    if (~exist(out_path,'dir')); mkdir(out_path);end
    
    for j=1:size(mask,1)
      try
        getfeat_single_video(datapath,idxinfo(mask(j)),out_path);
      catch
        disp(['I/O Error on :',num2str(idxinfo(mask(j)))]);  
      end
        cd(root);clc;
    end   %end of j
  end  %end of i
  
  
  
end

%load a specific action classes mask info.
function [mask]=load_mask_fromfile(action_mask_path)
  fid=fopen(action_mask_path,'r');
  mask=fscanf(fid,'%d');
  mask=find(mask==1);   %retun the pos of mask=1;
end

%Get action classes by scan mask directories.
function [action_classes]=get_action_classes(mask_path)
  cd(mask_path);
  tmp_action_classes=struct2cell(dir);
  tmp_action_classes=tmp_action_classes(1,:);
  action_classes={};
  total=0;
  for i=1:size(tmp_action_classes,2)
    if (~isempty(strfind(tmp_action_classes{1,i},'.label')))
        total=total+1;
        str=(tmp_action_classes{1,i});
        action_classes{total}=str(1:4);
    end
  end
  
  %Assert: the size should be exactly 18.
  if (size(action_classes,2)~=18)
      error('Assertion failed: the classes number is not 18');
  end
  
end


%Load idx file info.
function [idxinfo]=load_idxinfo(idxpath)
  idxinfo=[];
  fid=fopen(idxpath,'r');
  while (~feof(fid))
     tmpstr=fgets(fid);
     idxinfo=[idxinfo;str2num(tmpstr)];
  end
  fclose(fid);
end

%Get present path.
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
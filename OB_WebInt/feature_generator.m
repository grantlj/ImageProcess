function [] = feature_generator()
addpath(genpath('VideoUtils_1_2_4'));
%   if (nargin<1); dev_evl=0;  end    %dev_evl=0 means training set.
%                                     %dev_evl=1 means test set.
%   
%   switch(dev_evl)
%       case 0
%           dev_evl_path='dataset_MED/train/';
%           mask_path='dataset_MED/dev/';
%           idx_path='dataset_MED/training.idx';
%       case 1
%           dev_evl_path='dataset_MED/test/';
%           mask_path='dataset_MED/evl/';
%           idx_path='dataset_MED/evl.idx';
%       otherwise
%           error('invalid input parameter...');
%   end
%  
%  if (~exist(dev_evl_path,'dir'))
%      mkdir(dev_evl_path);
%  end
%  
%  datapath='/data/gaocq/MED11_small_9746/dataset9746/';
 %datapath='D:/Matlab/ImageProcess/OBMED/';
 
 
 %%
  ut_set_path={'D:/dataset/WEB_interaction_v2.0/chase/','D:/dataset/WEB_interaction_v2.0/exchange_object/',...
              'D:/dataset/WEB_interaction_v2.0/handshake/','D:/dataset/WEB_interaction_v2.0/highfive/',...
              'D:/dataset/WEB_interaction_v2.0/hug/','D:/dataset/WEB_interaction_v2.0/hustle/',...
              'D:/dataset/WEB_interaction_v2.0/kick/','D:/dataset/WEB_interaction_v2.0/kiss/','D:/dataset/WEB_interaction_v2.0/pat/'...
 };  %dataset path.

 feature_set_path={'feature/chase/','feature/exchange_object/',...
              'feature/handshake/','feature/highfive/',...
              'feature/hug/','feature/hustle/',...
              'feature/kick/','feature/kiss/','feature/pat/'};                                     %corresponding feature saving path.
          
  %%       
          
  root=GetPresentPath();
  
  
  %cd(root);clc;
  
  for i=1:size(ut_set_path,2)
   
  
    out_path=feature_set_path{i};  %feature output path;
    if (~exist(out_path,'dir')); mkdir(out_path);end
    
    for j=1:50
     % try
        getfeat_single_video(ut_set_path{i},j,out_path);
    %  catch
        disp(['I/O Error on :',ut_set_path{i},':',num2str(j)]);  
     % end
       % cd(root);clc;
    end   %end of j
  

end  %end of i
  
  
  
end

%Get present path.
function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
disp(p1);
i=findstr(p1,'/');
if (isempty(i))         %Differ between Linux and featuren
    i=findstr(p1,'\');
end
disp(i);
p1=p1(1:i(end));
res=p1;
end
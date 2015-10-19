function [] = main_tester()
 addpath(genpath('liblinear-2.1/'));
 pos_img_root_path='D:/dataset/Head/images/pos/';
 neg_img_root_path='D:/dataset/Head/images/neg/';
 pos_trn_count=5340-500; neg_trn_count=5163-500;
 pos_tst_count=500;  neg_tst_count=500;
 vl_setupnn;
 net_split_position=[2,5,7,8];
 
%  svmmodels={};
%  for i=1:size(net_split_position,2)
%    net_filename=['present_net_layer_',num2str(net_split_position(i)),'.mat'];
%    load(net_filename);
%    
%    [now_pos_train_set,now_pos_train_label]=get_dataset(net_split_position(i),net_trained,pos_img_root_path,1,pos_trn_count,1);
%    [now_neg_train_set,now_neg_train_label]=get_dataset(net_split_position(i),net_trained,neg_img_root_path,1,neg_trn_count,-1);
%    now_train_set=[now_pos_train_set;now_neg_train_set];now_train_label=[now_pos_train_label;now_neg_train_label];
%    
%    svmmodel=train(now_train_label,sparse(double(now_train_set)),'-s 2');
%    svmmodels{i}=svmmodel;
%  end
%  
%  save('cascade_svmmodels.mat','svmmodels');

%%
load('cascade_svmmodels.mat');

'Generating testing file paths...'
%[pos_test_set,pos_test_label]=get_dataset_for_cascade(net_split_position,pos_img_root_path,pos_trn_count+1,pos_trn_count+pos_tst_count,1);
[neg_test_set,neg_test_label]=get_dataset_for_cascade(net_split_position,neg_img_root_path,neg_trn_count+1,neg_trn_count+neg_tst_count,-1);
test_set=[neg_test_set]; test_label=[neg_test_label];

%%
cascade_hist=zeros(1,size(svmmodels,2));
tic
accuracy=0;

for i=1:size(test_label,1)
  
  for cascade_index=1:size(svmmodels,2)
    svmmodel=svmmodels{cascade_index};
    now_feat=test_set{i,cascade_index};
    [now_predict_label,~,~]=predict(test_label(i),sparse(double(now_feat)),svmmodel);
    if (now_predict_label==-1)
        break;
    end
  end
  cascade_hist(cascade_index)=cascade_hist(cascade_index)+1;
  if (now_predict_label==test_label(i)) 
      accuracy=accuracy+1;
  end
end
toc
accuracy/size(test_label,1)
bar(cascade_hist);
end

%%
function [dataset, label]=get_dataset_for_cascade(net_split_position,img_root_path,st,en,tag)
 label=[];
 datamean_path='D:/dataset/Head/data_mean.mat';
 load(datamean_path);

 if (tag==1)
     sufix='pos';
 else
     sufix='neg';
 end
 
 dataset={};
 
 nets={};
 
 %Prepare the net!
 for i=1:size(net_split_position,2)
   load(['present_net_layer_',num2str(net_split_position(i)),'.mat']);
   net_trained.layers=net_trained.layers(1:end-1);
   nets{i}=net_trained;
 end
 
 %Extract test feature.
  for i=st:en
        i
         for feat_index_count=1:size(net_split_position,2)
           net_trained=nets{feat_index_count};
           feat_index=net_split_position(feat_index_count);
           feat_filename=['feat/',sufix,'_image_',sprintf('%04d',i),'_',num2str(feat_index),'.mat'];

        %  if (~exist(feat_filename,'file'))
            img_filename=[img_root_path,'image_',sprintf('%04d',i),'.jpg'];
            im=imread(img_filename); im=imresize(im,[28,28]);
            im=double(im)-data_mean;
            im=single(im);
            res=vl_simplenn(net_trained,im);
            tmp_feat=gather(res(end-2).x(:)');
            save(feat_filename,'tmp_feat');
        %   end

        load(feat_filename);
%         if (i==st)
%             dataset=zeros(en-st+1,size(tmp_feat,2));
%         end
        dataset{i-st+1,feat_index_count}=tmp_feat;
         end %end of feat_index
      label=[label;tag];
  end %end of i

end

%%
function [dataset, label]=get_dataset(feat_index,net_trained,img_root_path,st,en,tag)
 label=[];
 datamean_path='D:/dataset/Head/data_mean.mat';
 load(datamean_path);
 net_trained.layers=net_trained.layers(1:end-1);
 if (tag==1)
     sufix='pos';
 else
     sufix='neg';
 end
  for i=st:en
    i
    feat_filename=['feat/',sufix,'_image_',sprintf('%04d',i),'_',num2str(feat_index),'.mat'];
    
  %  if (~exist(feat_filename,'file'))
        img_filename=[img_root_path,'image_',sprintf('%04d',i),'.jpg'];
        im=imread(img_filename); im=imresize(im,[28,28]);
        im=double(im)-data_mean;
        im=single(im);
        res=vl_simplenn(net_trained,im);
        tmp_feat=gather(res(end-2).x(:)');
        save(feat_filename,'tmp_feat');
 %   end
    
    load(feat_filename);
    if (i==st)
        dataset=zeros(en-st+1,size(tmp_feat,2));
    end
    dataset(i-st+1,:)=tmp_feat; label=[label;tag];
  end

end


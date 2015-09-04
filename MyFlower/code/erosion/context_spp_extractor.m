%pure context+spp method acheive 75.5% accuracy?
vl_setupnn;
clc;
clear all;
level=15;  %layer 19
load('net-epoch-x.mat');
data_splits_path='D:\dataset\oxfordflower102\setid.mat';
data_mean_path='D:\dataset\oxfordflower102\data_mean.mat';
truth_path='D:\dataset\oxfordflower102\imagelabels.mat';
img_raw_path='D:\dataset\oxfordflower102\jpg\';


root_img_bdx_path='D:\dataset\oxfordflower102\bdx_info_d';
root_feature_path='D:\dataset\oxfordflower102\ZUO\feat_spp_context_d';


load(data_splits_path);  %train, val, test split
load(truth_path);        %groundtruth.
load(data_mean_path);data_mean=images.data_mean;  %image_mean

data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
net.layers{end}.type = 'softmax';
total=0;
trn1=[trnid,valid];  %use both val and test set.
truth=labels;


for dilate_index=1:5
       
         img_bdx_path=[root_img_bdx_path,num2str(dilate_index),'\'];
         feature_path=[root_feature_path,num2str(dilate_index),'\'];
         mkdir(feature_path);
        'Loading training data...'
        train_feat=zeros(size(trn1,2),10752); train_label=[];  %for feature and label, respectively.
        for i=1:size(trn1,2)

         img_count=trn1(1,i);
         img_count
         filename=[img_raw_path,'image_',sprintf('%05d',img_count),'.jpg'];
         feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
         image_seg_filename=[img_bdx_path,'bdx_',sprintf('%05d',img_count),'.mat'];  %image-segmentation file.
         label=truth(img_count);
         %im=imread(filename);
        % res=vl_simplenn(net,single(im));
         if (~exist(feat_filename,'file'))

             im=imread(filename);  %raw image.
             load(image_seg_filename); %segmentation info.
            % im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
             data_mean_now=imresize(data_mean,[size(im,1),size(im,2)]);
             im=double(im)-data_mean_now;
             try
             im(y_min:y_max,x_min:x_max)=data_mean_now(y_min:y_max,x_min:x_max);  %Ç°¾°Ìî³ämeanÍ¼
             catch
             end
             im=single(im);

        %  im=gpuArray(im);
        % label=truth(img_count);

         res=vl_simplenn(net,im);
         %tmp_feat=gather(res(level).x(:)');
         tmp_feat=[get_spp_feat(res(level).x,1,1,width,height,height,width)];
         save(feat_filename,'tmp_feat');
         else
              load(feat_filename);
         end

        %  train_feat=[train_feat;tmp_feat];
       %   train_feat(i,:)=tmp_feat;
        % train_label=[train_label;label];

        end
        %%
        'Loading test data...'
        tst1=tstid;
        test_feat=zeros(size(tst1,2),10752);test_label=[];
        for i=1:size(tst1,2)
         img_count=tst1(1,i);
         img_count
         filename=[img_raw_path,'image_',sprintf('%05d',img_count),'.jpg'];
         feat_filename=[feature_path,'image_',sprintf('%05d',img_count),'.mat'];
         image_seg_filename=[img_bdx_path,'bdx_',sprintf('%05d',img_count),'.mat'];  %image-segmentation file.
         label=truth(img_count);  
         if (~exist(feat_filename,'file'))
             im=imread(filename);  %raw image.
             load(image_seg_filename); %segmentation info.
            % im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
             data_mean_now=imresize(data_mean,[size(im,1),size(im,2)]);
             im=double(im)-data_mean_now;
             try
             im(y_min:y_max,x_min:x_max)=data_mean_now(y_min:y_max,x_min:x_max); %Ç°¾°Ìî³ämeanÍ¼
             catch
             end
             %im=double(im)-data_mean;
             im=single(im);

        %  im=gpuArray(im);
        % label=truth(img_count);

         res=vl_simplenn(net,im);
         %tmp_feat=gather(res(level).x(:)');
         tmp_feat=[get_spp_feat(res(level).x,1,1,width,height,height,width)];
         save(feat_filename,'tmp_feat');

         else
             load(feat_filename);
         end


        % test_feat=[test_feat;tmp_feat];
         %test_feat(i,:)=tmp_feat;
        % test_label=[test_label;label];

        end
end



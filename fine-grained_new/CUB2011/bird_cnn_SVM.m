 %vl_setupnn;
%layer 33: 53.9351%
%layer 34: 56.127%
%layer 35: 53.0894%
%layer 36: 54.3493%

  levels=[34] ;                    %33 34 35 36
  acc_list=[];
  %%
  %Accuracy: level 19: 
  %All based on vgg-16 net
  %%
  net=load('D:\dataset\models\imagenet-vgg-verydeep-16.mat');
  net=vl_simplenn_move(net,'cpu');
  data_splits_path='D:\dataset\CUB_200_2011\setid.mat';
  data_mean_path='D:\dataset\CUB_200_2011\data_mean.mat';
  truth_path='D:\dataset\CUB_200_2011\imagelabels.mat';
  feature_root_path='D:\dataset\CUB_200_2011\feat_raw_image_vgg19';
  
  load(data_splits_path);
  load(truth_path);
  load(data_mean_path);data_mean=images.data_mean;
  
  data_mean=imresize(data_mean,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
  net.layers{end}.type = 'softmax';
  total=0;
  %tst1=[tst1,val1,trn1];
  
  trn1=trnid;  %use both val and test set.
  truth=labels;
  
  
  for layer_count=1:size(levels,2)
         level=levels(layer_count);
         feature_path=[feature_root_path,'_',num2str(levels(layer_count)),'\'];
         mkdir(feature_path);
         'Loading training data...'
          train_feat=zeros(size(trn1,2),4096); train_label=[];  %for feature and label, respectively.
           for i=1:size(trn1,2)
             img_count=trn1(1,i);
             img_count
             filename=['D:/dataset/CUB_200_2011/images/images/','image_',sprintf('%06d',img_count),'.jpg'];
             feat_filename=[feature_path,'image_',sprintf('%06d',img_count),'.mat'];

             label=truth(img_count);

             if (~exist(feat_filename,'file'))
             im=imread(filename);
             im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);

             if (size(im,3)==1) 
                 im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,1);
             end
             im=double(im)-data_mean;
             im=single(im);

             res=vl_simplenn(net,im);
             tmp_feat=gather(res(level).x(:)');
             save(feat_filename,'tmp_feat');
             else
                  load(feat_filename);
             end
             train_feat(i,:)=tmp_feat;
             train_label=[train_label;label];
           end
           %%
            'Loading test data...'
            tst1=tstid;
            test_feat=zeros(size(tst1,2),4096);test_label=[];
            for i=1:size(tst1,2)
             img_count=tst1(1,i);
             img_count
             filename=['D:/dataset/CUB_200_2011/images/images/','image_',sprintf('%06d',img_count),'.jpg'];
             feat_filename=[feature_path,'image_',sprintf('%06d',img_count),'.mat'];
               label=truth(img_count);
             if (~exist(feat_filename,'file'))

             im=imread(filename);
             im=imresize(im,[net.normalization.imageSize(1,1),net.normalization.imageSize(1,2)]);
             if (size(im,3)==1) 
                 im(:,:,2)=im(:,:,1);im(:,:,3)=im(:,:,1);
             end

             im=double(im)-data_mean;
             im=single(im);
            % im=gpuArray(im);


             res=vl_simplenn(net,im);
             tmp_feat=gather(res(level).x(:)');
             save(feat_filename,'tmp_feat');

             else
                 load(feat_filename);
             end


            % test_feat=[test_feat;tmp_feat];
             test_feat(i,:)=tmp_feat;
             test_label=[test_label;label];

            end
        %%
        %Training SVM...
        
        [bestCVaccuarcy,bestc,bestg,ga_option] = gaSVMcgForClass(train_label,train_feat)
        
        svmmodel=svmtrain(train_label,train_feat,'-s 0 -t 0');
        clear train_label;
        clear train_feat;
        [predict_label, accuracy, prob] = svmpredict(test_label, test_feat, svmmodel);
        acc_list=[acc_list;accuracy(1,1)];
        clear test_label; clear test_feat;
end % end of layer

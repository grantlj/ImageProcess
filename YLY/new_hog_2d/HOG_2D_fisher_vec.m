clear all;
clc;

%run('D:\vlfeat\vlfeat-0.9.18\toolbox\vl_setup');


ut_set_path={'WI/chase/','WI/exchange_object/',...
              'WI/handshake/','WI/highfive/',...
              'WI/hug/','WI/hustle/',...
              'WI/kick/','WI/kiss/','WI/pat/'...
 };  %dataset path.

cls = {'chase','exchange_object','handshake','highfive','hug','hustle','kick','kiss','pat'};
dimension = 198400;

data_all = [];
data = [];
    
for seq =1:1:floor(50/5)
   data_sel(seq) = seq*5;
end

   
    % from X, the chosen columns form Y and their column index is in SEL
    
    %generate a codebook of training data
    for cls_num = 1:1:9
        % for seq_num = 1:1:2
        for seq =1:1:length(data_sel)  %only the training data
            load(['WI/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',data_sel(seq)),'-HOGFeature.mat']);     
            for i=1:size(feat_raw,2)
              data_frame=feat_raw{i};
              for j=1:size(data_frame,1)
                  for k=1:size(data_frame,2)
                    data=[data;reshape(data_frame(j,k,:),1,31)];
                  end
              end
            end
        end
        % end
    end
    
    data=data';
    
    tic;
    numClusters =256 ;  %according to Xuanchong Li
    [means, covariances, priors] = vl_gmm(data, numClusters);
    toc;
    
    % fisher vector for all data (train&val)
    % for seq_num = 1:1:2
    for cls_num = 1:1:6
        for seq =1+(set_num-1)*10:1:10+(set_num-1)*10
            
            numDataToBeEncoded = 3000;  %according to Xuanchong Li
            data_struct = load(['H:\study\HOG_2D\exp1\',char(cellstr(cls(cls_num))),'\set',int2str(set_num),'\HOG_2D_2by2add1_discriptor_',sprintf('%06d',seq)]);
%             dataToBeEncoded = data_struct(:,starting_column:ending_column)';
                  dataToBeEncoded = data_struct.hog;
            encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
            
            save(['H:\study\HOG_2D\exp1\',char(cellstr(cls(cls_num))),'\fisher_vec\fisher_vec_HOG_2by2_',sprintf('%06d',seq),'.mat'],'encoding');
        end
    end

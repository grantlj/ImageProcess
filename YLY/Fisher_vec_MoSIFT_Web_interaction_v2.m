clear all;
clc;
cls = {'chase','exchange_object','handshake','highfive','hug','hustle','kick','kiss','pat'};



%sampling data_tmp to avoid OUT OF MEMORY
    data_all = [];
    data = [];
    
    for seq =1:1:50
        data_all(seq) = seq;
    end
    [row,column] = size(data_all);
    data_sel = vl_colsubset(data_all,round(column/10)); %[Y,SEL] = vl_colsubset(X,n) randomly choose n columns
    % from X, the chosen columns form Y and their column index is in SEL
    
    %generate a codebook of training data
    for cls_num = 1:1:9
        for seq =1:1:length(data_sel)  %only the training data
            
            data_struct = load(['D:/output/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',data_sel(seq)),'.txt']);  %D:\������output�ļ��е�·��
            data = [data data_struct']; %stich all the training data into variable 'data'
        
        end
    end
    
    
    
    tic;
    numClusters = 256 ;
    [means, covariances, priors] = vl_gmm(data, numClusters);
    toc;
    
    % fisher vector for all data (train&val)
   
    mkdir('D:/','mosift_fish_encoding');  %D:\������output�ļ��е�·��
    for cls_num = 1:1:9
       
        mkdir('D:/mosift_fish_encoding',char(cellstr(cls(cls_num))));  %D:\������output�ļ��е�·��
        
        for seq =1:1:50
            
            data_struct = load(['D:/output/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',seq),'.txt']);  %D:\������output�ļ��е�·��
            dataToBeEncoded = data_struct';
            encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);

            save(['D:/mosift_fish_encoding/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',seq),'.mat'],'encoding');  %D:\������output�ļ��е�·��
        end
    end

clear all;
clc;
cls = {'chase','exchange_object','handshake','highfive','hug','hustle','kick','kiss','pat'};

feature = [];

mkdir('D:\yly_3dsift_feature','3DSIFT_feature');    %your path是你存放解压后的3dSIFT特征文件夹的路径
for cls_num = 1:1:9
    
    
    mkdir('D:\yly_3dsift_feature\3DSIFT_feature',char(cellstr(cls(cls_num))));  %your path是你存放解压后的3dSIFT特征文件夹的路径
    
    for seq = 1:1:50
        
        tmp = load(['D:\yly_3dsift_feature\3dsift\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',seq),'_',char(cellstr(cls(cls_num))),'.mat']);
        for loop = 1:1:length(tmp.keys)
            feature(loop,:) = tmp.keys{1,loop}.ivec;
        end
        save(['D:\yly_3dsift_feature\3DSIFT_feature\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',seq),'.mat'],'feature');  %your path是你存放解压后的3dSIFT特征文件夹的路径
        feature = [];  %release feature
        
    end
end

vl_setup;
%run('your_vlfeat_path/vlfeat/vlfeat-0.9.18/toolbox/vl_setup');  %your_vlfeat_path是你存放vlfeat文件夹的路径

%sampling data_tmp to avoid OUT OF MEMORY
    data_all = [];
    data = [];
    
    for seq =1:1:50
        data_all(seq) = seq;
    end
    [row,column] = size(data_all);
    data_sel = vl_colsubset(data_all,round(column/12)); %[Y,SEL] = vl_colsubset(X,n) randomly choose n columns
    % from X, the chosen columns form Y and their column index is in SEL
    
    %generate a codebook of training data
    for cls_num = 1:1:9
        for seq =1:1:length(data_sel)  %only the training data
            
            data_struct = load(['D:\yly_3dsift_feature\3dsift_feature/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',data_sel(seq)),'.mat']);  %your path是你存放解压后的3dSIFT特征文件夹的路径
            data = [data data_struct.feature']; %stich all the training data into variable 'data'
        
        end
    end
    
    
    
    tic;
    numClusters = 256 ;
    [means, covariances, priors] = vl_gmm(data, numClusters);
    toc;
    
    % fisher vector for all data (train&val)
   
    for cls_num = 1:1:9
        
        mkdir('D:\yly_3dsift_feature\fish_encoding',char(cellstr(cls(cls_num))));  %your path是你存放解压后的3dSIFT特征文件夹的路径
        
        for seq =1:1:50
            
            data_struct = load(['D:\yly_3dsift_feature\3dsift_feature/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',seq),'.mat']); %your path是你存放解压后的3dSIFT特征文件夹的路径
            dataToBeEncoded = data_struct.feature';
            encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);

            save(['D:\yly_3dsift_feature/fish_encoding/',char(cellstr(cls(cls_num))),'/',sprintf('%06d',seq),'.mat'],'encoding');  %your path是你存放解压后的3dSIFT特征文件夹的路径
        end
    end

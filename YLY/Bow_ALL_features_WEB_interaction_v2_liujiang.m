clear all;
clc;
%run('E:\software\vlfeat\vlfeat-0.9.18\toolbox\vl_setup');
vl_setup;
cls = {'chase','exchange_object','handshake','highfive','hug','hustle','kick','kiss','pat'};
experi_folder = {'Traj','HOG','HOF','MBHx','MBHy','HOGHOF','MBHxMBHy','TrajHOG','TrajHOF','TrajHOGHOF','TrajMBHx','TrajMBHy','TrajMBHxMBHy','HOGHOFMBHxMBHy','ALL','STIP','3DSIFT','MoSIFT'};

for experi_num = 17:1:17
    
    data_all = [];
    data = [];
    
    %sampling to avoid out of Memory
    for seq =1:1:50
        data_all(seq) = seq;
    end
    [row,column] = size(data_all);
    data_sel = vl_colsubset(data_all,round(column/6)); %[Y,SEL] = vl_colsubset(X,n) randomly choose n columns
    % from X, the chosen columns form Y and their column index is in SEL
    
    % training data
    for cls_num = 1:1:9
        for seq =1:1:length(data_sel)  %only the training data
            if (experi_num==17)
               
              data_struct = load(['D:\YLY\',char(cellstr(experi_folder(experi_num))),'_raw\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',data_sel(seq)),'.mat']);  %D:\YLY is the path that you hold all the raw feature folders
            else
              data_struct = load(['D:\YLY\',char(cellstr(experi_folder(experi_num))),'_raw\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',data_sel(seq)),'.txt']);  
            end
              data = [data data_struct.feature']; %stich all the training data into variable 'data'
        end
    end
    
    
    % generate a codebook using kmeans
    tic;
    numClusters = 1000 ;  %k=1000, according to state-of-art
   % [centers,assignments] = vl_kmeans(data, numClusters);
    load('D:/YLY/storage/centers_3dsift.mat');
    
    toc;
    
    kdtree = vl_kdtreebuild(centers);
    
    %generate vectors
    for cls_num = 1:1:9
        mkdir(['D:\YLY\storage\',char(cellstr(experi_folder(experi_num))),'_BoW'],char(cellstr(cls(cls_num))));   %storage path is the path that you hold all the BoW vectors
        for seq = 1:1:50
            disp(['Handling:',char(cellstr(cls(cls_num))),'-',num2str(seq)]);
            data_struct = load(['D:\YLY\',char(cellstr(experi_folder(experi_num))),'_raw\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',seq),'.mat']);  %D:\YLY is the path that you hold all the raw feature folders
            data_struct=data_struct.feature;
            [row,column] = size(data_struct);
            encoding = zeros(1,999);
            for data_point = 1:1:row
                Q = data_struct(data_point,:)';
                [index,distances] = vl_kdtreequery(kdtree,centers,Q);
                encoding(1,index) = encoding(1,index)+1;
            end
            save(['D:\YLY\storage\',char(cellstr(experi_folder(experi_num))),'_BoW\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',seq),'.mat'],'encoding');   %storage path is the path that you hold all the BoW vectors
        end
    end
    
    system('shutdown -s');
    
    
end
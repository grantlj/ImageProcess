% 以下是给Web-interaction_v2.0的STIP以及15种Dense Trajetory feature的训练（已用fisher vector做过pooling）
% 10-fold cross validation来获得AP,每1个fold包含5个样本
clear all;
clc;
cls = {'chase','exchange_object','handshake','highfive','hug','hustle','kick','kiss','pat'};
experi_folder = {'Traj','HOG','HOF','MBHx','MBHy','HOGHOF','MBHxMBHy','TrajHOG','TrajHOF','TrajHOGHOF','TrajMBHx','TrajMBHy','TrajMBHxMBHy','HOGHOFMBHxMBHy','ALL','STIP','3DSIFT','MoSIFT','SIFT'};

for experi_num = 19:1:19
    
    mkdir('D:\YLY\new_fusion_test\storage\','b_1_c_100');
    
    
    result = [];
    score = [];
    accuracy_vector = [];
    
    for test_fold = 1:1:10   %每一次换一个test的seq
        %---------------------------------------------------------------------------------------------------------------------
        %                                                                                               load feature and label
        %---------------------------------------------------------------------------------------------------------------------
        %---------------------------training data------------------------
        training_instance_matrix = [];
        training_label_vector = [];
        testing_instance_matrix = [];
        testing_label_vector = [];
        training_ordinal = [];
        
        %用training_ordinal保存训练样本的序号
        test_begin = (test_fold-1) * 5 + 1;
        test_end = test_begin + 4;
        for ordinal = [1:test_begin-1,test_end+1:50]
            training_ordinal = [training_ordinal;ordinal];
        end
        
        
        for cls_num = 1:1:9
            for seq_pnt = 1:1:45 %seq_pnt用来指向training_ordinal中的每一个元素
                
                %             feature_struct = load(['E:\yly\dense
                %             trajectory\WEB_interaction_v2.0\gmm_cluster_256\',char(cellstr(experi_folder(experi_num))),'\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',training_ordinal(seq_pnt))]);
                feature_struct = load(['D:\YLY\new_fusion_test\feature\SIFT\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',training_ordinal(seq_pnt))]);  %for STIP
                feature = feature_struct.encoding;
                training_instance_matrix = [training_instance_matrix;feature'];
                training_instance_matrix = double(training_instance_matrix);
                training_label_vector = [training_label_vector;cls_num];
                
            end
        end
        
        %---------------------------testing data------------------------
        for cls_num = 1:1:9
            for test_seq_num = test_begin:1:test_end
                
                %            feature_struct = load(['E:\yly\dense trajectory\WEB_interaction_v2.0\gmm_cluster_256\',char(cellstr(experi_folder(experi_num))),'\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',test_seq_num)]);
                feature_struct = load(['D:\YLY\new_fusion_test\feature\SIFT\',char(cellstr(cls(cls_num))),'\',sprintf('%06d',test_seq_num)]);  %for STIP
                
                feature = feature_struct.encoding;
                testing_instance_matrix = [testing_instance_matrix;feature'];
                testing_instance_matrix = double(testing_instance_matrix);
                testing_label_vector = [testing_label_vector;cls_num];
                
            end
        end
        
        %---------------------------------------------------------------------------------------------------------------------
        %                                                                                           train with SVM from libsvm
        %---------------------------------------------------------------------------------------------------------------------
        model = svmtrain(training_label_vector, training_instance_matrix, '-s 0 -t 0 -b 1 -c 100');
        %---------------------------------------------------------------------------------------------------------------------
        %                                                                                           test with SVM from libsvm
        %---------------------------------------------------------------------------------------------------------------------
        [predicted_label, accuracy,prob_estimate] = svmpredict(testing_label_vector, testing_instance_matrix, model','-b 1');
        score = [score prob_estimate];
        result = [result predicted_label];
%         save(['F:\yly\SIFT\WEB_interaction\gmm_cluster_256\b_1_c_100\model',num2str(test_fold),'.mat'],'model'); %保存model用于单独某部分样本的识别AP检测
        %     pause;
    end
    save(['D:\YLY\new_fusion_test\storage\b_1_c_100\result.mat'],'result');
    save(['D:\YLY\new_fusion_test\storage\b_1_c_100\score.mat'],'score');
end
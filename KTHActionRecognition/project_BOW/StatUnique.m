function [] = StatUnique( input_args )
 filename='D:\Matlab\ImageProcess\KTHActionRecognition\project_BOW\running\test.mat';
 load(filename);
 b=unique(huMat,'rows');
end


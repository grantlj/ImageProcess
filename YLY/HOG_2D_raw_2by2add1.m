clear all;
clc;

%run('E:\software\vlfeat\vlfeat-0.9.18\toolbox\vl_setup');
cls = {'chase','exchange_object','handshake','highfive','hug','hustle','kick','kiss','pat'};
cellSize = 8;

for cls_num = 1:1:9
    for set_num =1:1:2
        for seq_num = 1+(set_num-1)*10:1:10+(set_num-1)*10
            folder_path = strcat('H:\study\UT-interaction\',char(cellstr(cls(cls_num))),'\',char(cellstr(cls(cls_num))),'_',int2str(set_num),'\reduced_image\seq',int2str(seq_num));
            im_all = dir([folder_path,'\*.jpg']);
            num_image = length(im_all);
            hog = [];
            for im_num = 1:1:num_image-1
                im = imread([folder_path,'\',im_all(im_num).name]);
                [height, width, dim] = size(im);
                im = single(im);
                im1 = imresize(im,[64,128]);
                im2 = imresize(im(1:floor(height/2),1:floor(width/2),:),[64,128]);
                im3 = imresize(im(1:floor(height/2),floor(width/2):width,:),[64,128]);
                im4 = imresize(im(floor(height/2):height,1:floor(width/2),:),[64,128]);
                im5 = imresize(im(floor(height/2):height,floor(width/2):width,:),[64,128]);
                hog1 = vl_hog(im1, cellSize, 'verbose');
                hog2 = vl_hog(im2, cellSize, 'verbose');
                hog3 = vl_hog(im3, cellSize, 'verbose');
                hog4 = vl_hog(im4, cellSize, 'verbose');
                hog5 = vl_hog(im5, cellSize, 'verbose');
                hog = [hog hog1(:);hog2(:);hog3(:);hog4(:);hog5(:)];
            end
            save(['H:\study\HOG_2D\exp1\',char(cellstr(cls(cls_num))),'\set',int2str(set_num),'\HOG_2D_2by2add1_discriptor_',sprintf('%06d',seq_num)],'hog');
        end
    end
end
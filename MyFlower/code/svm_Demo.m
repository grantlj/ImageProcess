function [] = svm_Demo(im_path)
 
  class_count=17;
  
  %im_path='test3.jpg';
  im=imread(im_path);
  h_raw=size(im,1);w_raw=size(im,2);
  
  %get json file name.
  json_path=strrep(im_path,'.jpg','.json');
  
  %resize if too big.
  if (h_raw>600)
      im=imresize(im,600/h_raw);
  end
  
  %extracting raw feature.
  disp('Extracting raw feature...');
  tic;
  raw_feat.imsize=[size(im,1),size(im,2)];  %size: height*width.
  raw_feat.hsv_feat=get_hsv_feat(im);
  raw_feat.shape_feat=get_shape_feat(im);
  raw_feat.texture_feat=get_texture_feat(im);
  toc;
  
  %load centers per-trained.
%   hsv_center_path='../dataset/hsv_words_centers.mat';
%   texture_center_path='../dataset/texture_words_centers.mat';
%   shape_center_path='../dataset/shape_words_centers.mat';
  
  hsv_center_path='hsv_words_centers.mat';
  texture_center_path='texture_words_centers.mat';
  shape_center_path='shape_words_centers.mat';
 
  tic;
  load(hsv_center_path);
  hsv_center=centers;
  hsv_tree=vl_kdtreebuild(centers);
 
  load(shape_center_path);
  shape_center=centers;
  shape_tree=vl_kdtreebuild(centers);
 
  load(texture_center_path);
  texture_center=centers;
  texture_tree=vl_kdtreebuild(centers);
   
  %generate final bag-of-words feature.
   bow_feat=[0.4*hsv_vote(raw_feat.hsv_feat,hsv_tree,hsv_center),...
                  shape_vote(raw_feat.shape_feat,shape_tree,shape_center),...
                  texture_vote(raw_feat.texture_feat,texture_tree,texture_center)];
              
   toc;
   
   %conduct classificaton.
   disp('Doing classification...');
   tic;
   %svm_model_path='../dataset/svmmodel.mat';
   svm_model_path='svmmodel.mat';
   load(svm_model_path);
   [predict_label, accuracy, prob] = svmpredict(1,bow_feat, model,'-b 1');
   
   prob(2,:)=1:class_count;
   prob=prob';
   prob=sortrows(prob,1);
   
   
   for i=1:5
     disp([get_flower_name(prob(class_count-i+1,2)),' with prob:',num2str(prob(class_count-i+1,1))]);
     json_struct.data{i}.name=get_flower_name(prob(class_count-i+1,2));
     json_struct.data{i}.prob=prob(class_count-i+1,1);
  end
   disp(['Image :',im_path,' is classified as:',get_flower_name(predict_label),' Json file saved:',json_path]);
   
   %save json string.
   json_struct.class=get_flower_name(predict_label);
   json_str=savejson('ret',json_struct,struct('ParseLogical',1));
   fid=fopen(json_path,'w');
   fprintf(fid,char(json_str));
   fclose(fid);
   toc;

end

function [texture_feat]=get_texture_feat(im)
 texture_feat=MR8fast(rgb2gray(im));
end

function [shape_feat]=get_shape_feat(im)
  im_sift=single(rgb2gray(im));
  %imshow(im_sift,[]);
  [f,d]=vl_sift(im_sift);
  shape_feat=d';  %ordered by row.
end

function [hsv_feat]=get_hsv_feat(im)
  hsv_feat=rgb2hsv(im);
end

function [featvec] = MR8fast(im)
%computes MR8 filterbank using recursive Gaussian filters
%input: intensity image
%output: MR8 feature vector

in = double(im) - mean(mean(im));
in = in ./ sqrt(mean(mean(in .^ 2)));

ims = cell(1, 8);
i=1;

sfac = 1.0;
mulfac = 2.0;

s1 = 3*sfac; s2 = 1*sfac;
for j=0:2,
    for k=0:5,
        phi = (k/6.0)*180.0;
        
        im1 = anigauss_mex(in, s1, s2, phi, 0, 1);
        im2 = anigauss_mex(in, s1, s2, phi, 0, 2);

        % take max of abs response for first order derivative
        % Varma&Zisserman also take abs max of second order...
        im1 = abs(im1);
        %im2 = abs(im2);
        if (k==0)
            maxim1 = im1;
            maxim2 = im2;
        else
            maxim1 = max(maxim1, im1);
            maxim2 = max(maxim2, im2);
        end
    end

    ims{i} = maxim1; i=i+1;
    ims{i} = maxim2; i=i+1;

    % next octave
    s1 = s1*mulfac; s2 = s2*mulfac;
end

sigma = 10.0*sfac;

im1 = anigauss_mex(in, sigma, sigma, 0.0, 2, 0);
im2 = anigauss_mex(in, sigma, sigma, 0.0, 0, 2);
ims{i} = (im1+im2);
i=i+1;
ims{i} = anigauss_mex(in, sigma, sigma);

% just throw away 25 pixel border...(half support of sigma=10 filter)
[R,C] = size(ims{1});
for j=1:i,
    ims{j} = ims{j}(26:R-25,26:C-25);
end

featvec = [ims{8}(:) ims{7}(:) ims{1}(:) ims{3}(:) ims{5}(:) ims{2}(:) ims{4}(:) ims{6}(:)];

end

function [feat]=hsv_vote(hsv_feat,hsv_tree,hsv_center)
  disp('Calculating image color representation...');
  feat=zeros(1,size(hsv_center,2));
  for i=1:size(hsv_feat,1)
      for j=1:size(hsv_feat,2)
         tmp=[hsv_feat(i,j,1);hsv_feat(i,j,2);hsv_feat(i,j,3)];
         [index,~]=vl_kdtreequery(hsv_tree,hsv_center,tmp);
         feat(1,index)=feat(1,index)+1;
      end
  end
  feat=feat./sum(feat);
end

function [feat]=shape_vote(shape_feat,shape_tree,shape_center)
  disp('Calculating image shape representation...');
  feat=zeros(1,size(shape_center,2));
  for i=1:size(shape_feat,1)
    tmp=double(shape_feat(i,:)');
    [index,~]=vl_kdtreequery(shape_tree,shape_center,tmp);
     feat(1,index)=feat(1,index)+1;
  end
  feat=feat./sum(feat);
end

function [feat]=texture_vote(texture_feat,texture_tree,texture_center)
disp('Calculating image texture representation...');
feat=zeros(1,size(texture_center,2));
  for i=1:size(texture_feat,1)
    tmp=double(texture_feat(i,:)');
    [index,~]=vl_kdtreequery(texture_tree,texture_center,tmp);
     feat(1,index)=feat(1,index)+1;
  end
  feat=feat./sum(feat);
end
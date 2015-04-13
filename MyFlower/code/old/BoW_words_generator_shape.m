function [] = BoW_words_generator_shape()
 raw_feat_path='../dataset/raw_feat/';
 data_splits_path='../dataset/datasplits.mat';
 output_file_path='../dataset/shape_words_centers.mat';
 load(data_splits_path);
 
 img_count=1360;
 img_sample_count=400;
 
 feat_mat=rand(img_sample_count*img_count,128);

  total=0;
  for i=1:size(trn1,2)
     img_count=trn1(1,i);
     
     disp(['Handling:',num2str(i),'/',num2str(size(trn1,2))]);
     filename=[raw_feat_path,'image_',sprintf('%04d',img_count),'_raw_feat.mat'];
     load(filename);
     
   
     feat=raw_feat.shape_feat;
     
     sample_index_x=randperm(size(feat,1));
     sample_index_x=sample_index_x(1:img_sample_count);
     
     %sample_index_y=randperm(size(feat,2));
    % sample_index_y=sample_index_y(1:img_sample_count);
     
     for j=1:img_sample_count
       total=total+1;
       feat_mat(total,:)=feat(sample_index_x(j),:);
     end
  end
  
  disp('Doing Clusting...');
  [centers, assignments]=vl_kmeans(feat_mat', 400);
  save(output_file_path,'centers');
end


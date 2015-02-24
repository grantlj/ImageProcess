function [] = BoW_feat_generator()
 raw_feat_path='../dataset/raw_feat/';
 bow_feat_path='../dataset/bow_feat/';
 img_count=1360;
 
 hsv_center_path='../dataset/hsv_words_centers.mat';
 texture_center_path='../dataset/texture_words_centers.mat';
 shape_center_path='../dataset/shape_words_centers.mat';
 
 load(hsv_center_path);
 hsv_center=centers;
 hsv_tree=vl_kdtreebuild(centers);
 
 load(shape_center_path);
 shape_center=centers;
 shape_tree=vl_kdtreebuild(centers);
 
 load(texture_center_path);
 texture_center=centers;
 texture_tree=vl_kdtreebuild(centers);
 
 for i=1:img_count
    
    
    filename=[raw_feat_path,'image_',sprintf('%04d',i),'_raw_feat.mat'];
    outname=[bow_feat_path,'image_',sprintf('%04d',i),'_bow_feat.mat'];
    
    disp(['Handling img:',num2str(i),'...']);
    
    if (~(exist(outname,'file')))
        tic;
        load(filename);

        bow_feat=[0.4*hsv_vote(raw_feat.hsv_feat,hsv_tree,hsv_center),...
                  shape_vote(raw_feat.shape_feat,shape_tree,shape_center),...
                  texture_vote(raw_feat.texture_feat,texture_tree,texture_center)];

        save(outname,'bow_feat');
        toc;
    end
 end

  system('shutdown -s');
end

function [feat]=hsv_vote(hsv_feat,hsv_tree,hsv_center)
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
  feat=zeros(1,size(shape_center,2));
  for i=1:size(shape_feat,1)
    tmp=double(shape_feat(i,:)');
    [index,~]=vl_kdtreequery(shape_tree,shape_center,tmp);
     feat(1,index)=feat(1,index)+1;
  end
  feat=feat./sum(feat);
end

function [feat]=texture_vote(texture_feat,texture_tree,texture_center)
feat=zeros(1,size(texture_center,2));
  for i=1:size(texture_feat,1)
    tmp=double(texture_feat(i,:)');
    [index,~]=vl_kdtreequery(texture_tree,texture_center,tmp);
     feat(1,index)=feat(1,index)+1;
  end
  feat=feat./sum(feat);
end

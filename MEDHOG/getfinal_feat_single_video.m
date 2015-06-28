function []=getfinal_feat_single_video(videoid,out_path,centers,kdtree)
  
%   if (nargin<1)
%     videopath='test.avi';
%   end;
 disp(['Now handling:',num2str(videoid),'  under path;',out_path]); 
 if (~exist([out_path,num2str(videoid),'-HOG_FINAL_Feature.mat'],'file'))
         hog_raw_feat_path=[out_path,num2str(videoid),'-HOG_RAW_Feature.mat'];
         
         %load raw feat.
         load(hog_raw_feat_path);
         
         %backup the original feat in feat_raw, feat_raw will save the 
         %new bow fetures.
         hog_raw_feat=feat_raw;
         feat_raw=[];
         
         for i=1:size(hog_raw_feat,2)
            now_hog_raw=hog_raw_feat{i};
            if (isempty(now_hog_raw))
                continue;
            end
            
            %doing bag-of-words using centers and kdtree.
            now_vec=conduct_bow(now_hog_raw,centers,kdtree);
            feat_raw=[feat_raw;now_vec]; 
            
            
         
         end
         
        feature_max=max(feat_raw);
        feature_min=min(feat_raw);
        feature_mean=mean(feat_raw);
        feat_lag=lagrange_opt(feat_raw);
         
       save([out_path,num2str(videoid),'-HOG_FINAL_Feature.mat'],'feat_raw','feature_max','feature_min','feat_lag');
       disp(['Finish handling:',videopath]);
 end
end

%core function for conducting bag-of-words.
function [now_vec]=conduct_bow(now_frame_feat,centers,kdtree)
  now_vec=zeros(1,size(centers,2));
  now_frame_feat=reshape(now_frame_feat,size(now_frame_feat,1)*size(now_frame_feat,2),31);
  now_frame_feat=double(now_frame_feat');

  [index,~]=vl_kdtreequery(kdtree,centers,now_frame_feat);
  
  for i=1:size(index,2)
     now_vec(index(i))=now_vec(index(i))+1; 
  end
  
  now_vec=now_vec./sum(now_vec);

end
% %Get present path.
% function res=GetPresentPath()
% clc;
% p1=mfilename('fullpath');
% disp(p1);
% i=findstr(p1,'/');
% if (isempty(i))         %Differ between Linux and Win
%     i=findstr(p1,'\');
% end
% disp(i);
% p1=p1(1:i(end));
% res=p1;
% end
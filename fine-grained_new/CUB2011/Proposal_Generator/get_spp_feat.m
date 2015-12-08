function [vec] = get_spp_feat(crop_res)
if (isempty(crop_res) || size(crop_res,1)<16 || size(crop_res,2)<16)
  crop_res=imresize(crop_res,[16,16]);  
end

vec=[];
for i=1:size(crop_res,3)
   now_level_res=crop_res(:,:,i);
   %now_level_res=imresize(now_level_res,[25,25]);
   tmp_feat=recursive_spp(now_level_res,1);
   vec=[vec,tmp_feat];
end

end

function [tmp_feat]=recursive_spp(crop_res,depth)
  height=size(crop_res,1);width=size(crop_res,2);
  
 %try
  tmp_feat=max(max(crop_res));
  
  if (depth<3)
      tmp_feat=[tmp_feat,recursive_spp(crop_res(1:ceil(height/2),1:ceil(width/2)),depth+1),...
                         recursive_spp(crop_res(1:ceil(height/2),ceil(width/2)+1:width),depth+1),...
                         recursive_spp(crop_res(ceil(height/2)+1:height,1:ceil(width/2)),depth+1),...
                         recursive_spp(crop_res(ceil(height/2)+1:height,1:ceil(width/2)),depth+1)];
  end
 %catch
 %   pause; 
% end
  
end

function [vec] = get_spp_feat(res_map,x_min,y_min,x_max,y_max,height,width)
%res_height=height;
%res_width=width;
% res_map_new=[];
% for i=1:size(res_map,3)
%   res_map_new(:,:,i)=imresize(res_map(:,:,i),[res_height,res_width]);
% end
% 
% res_map=res_map_new;
res_height=size(res_map,1); res_width=size(res_map,2);

res_x_min=ceil(y_min/height*res_height); res_x_max=floor(y_max/height*res_height);
res_y_min=ceil(x_min/width*res_width); res_y_max=floor(x_max/width*res_width);

try
  crop_res=res_map(res_x_min:res_x_max,res_y_min:res_y_max,:);
catch
    crop_res=res_map;
end

if (isempty(crop_res) || size(crop_res,1)<16 || size(crop_res,2)<16)
    crop_res=res_map;
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

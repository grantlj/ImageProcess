function [str] = get_flower_name(index)
 
 %Oxford flower 17 dataset.
 flower_names={'daffodil','snowdrop','Lily Valley','bluebell',...
               'Crocus','Iris','Tigerlily','Tulip',...
               'fritillary','sunflower','daisy','colt foot',...
               'dandeLion','Cowslip','buttercup','windflower','pansy'};
 str=flower_names(index);
end


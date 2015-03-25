function [str] = get_flower_name(index)
 %modified version, with 3 new flowers.
 %Oxford flower 17 dataset.
 flower_names={'Daffodil','Snowdrop','Lily Valley','Bluebell',...
               'Crocus','Iris','Tigerlily','Tulip',...
               'Fritillary','Sunflower','Daisy','Colt Foot',...
               'Dandelion','Cowslip','Buttercup','Windflower','Pansy','Sakura','Paeonia','Nelumbo'};
 str=flower_names(index);
end


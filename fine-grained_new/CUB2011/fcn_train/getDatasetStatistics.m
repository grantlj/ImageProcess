function stats = getDatasetStatistics(imdb)

train = find(imdb.images.set == 1) ;

% Class statistics
% classCounts = zeros(201,1) ;
% for i = 1:numel(train)
%   fprintf('%s: computing segmentation stats for training image %d\n', mfilename, i) ;
%   lb = imread(imdb.images.seg_pathlist{train(i)}) ;
%   ok = lb < 255 ;
%   classCounts = classCounts + accumarray(lb(ok(:))+1, 1, [21 1]) ;
% end
% stats.classCounts = classCounts ;

% Image statistics
for t=1:numel(train)
  fprintf('%s: computing RGB stats for training image %d\n', mfilename, t) ;
  rgb = imread(imdb.images.im_pathlist{train(t)}) ;
  rgb = single(rgb) ;
 try
  z = reshape(permute(rgb,[3 1 2 4]),3,[]) ;
  n = size(z,2) ;
  
  rgbm1{t} = sum(z,2)/n ;
  rgbm2{t} = z*z'/n ;
  catch
      rgbm1{t}=rgbm1{t-1};
      rgbm2{t}=rgbm2{t-1};
  end
end
rgbm1 = mean(cat(2,rgbm1{:}),2) ;
rgbm2 = mean(cat(3,rgbm2{:}),3) ;

stats.rgbMean = rgbm1 ;
stats.rgbCovariance = rgbm2 - rgbm1*rgbm1' ;

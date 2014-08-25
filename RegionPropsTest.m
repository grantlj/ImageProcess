function RegionPropsTest(filename)
 l_origin=imread(filename);
 l_bw=im2bw(l_origin,graythresh(l_origin));
 center=regionprops(l_bw,'all');
 centroids = cat(1, center.Centroid);
 imshow(l_origin);
 hold on;
 axis normal;axis on;
 plot(centroids(:,1),centroids(:,2),'b*');
 hold off;
end
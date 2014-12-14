function feature = MaxGetSpatialPyramid(responsemap, nlevel)
feature = zeros(sum(4.^(0:nlevel-1)), 1);
k=0;
for i=1:nlevel
    ngrid = 2^(i-1);                %对当前response Map分割成ngrid来做。
    feature(k+1:k+(4.^(i-1))) = MaxGetSpatialPyramid_single(responsemap, ngrid); %最后不同的grid合在一起拼成一个大vector
    k = k + 4^(i-1);
end
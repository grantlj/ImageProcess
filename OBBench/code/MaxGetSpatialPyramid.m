function feature = MaxGetSpatialPyramid(responsemap, nlevel)
feature = zeros(sum(4.^(0:nlevel-1)), 1);
k=0;
for i=1:nlevel
    ngrid = 2^(i-1);                %�Ե�ǰresponse Map�ָ��ngrid������
    feature(k+1:k+(4.^(i-1))) = MaxGetSpatialPyramid_single(responsemap, ngrid); %���ͬ��grid����һ��ƴ��һ����vector
    k = k + 4^(i-1);
end
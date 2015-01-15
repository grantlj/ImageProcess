function feature = MaxGetSpatialPyramid_single(responsemap, ngrid)
[height, width] = size(responsemap);
gridw = floor((width - mod(width, ngrid)) / ngrid);
gridh = floor((height - mod(height, ngrid)) / ngrid);

x_st = 1:gridw:gridw*ngrid;
y_st = 1:gridh:gridh*ngrid;
x_ed = gridw:gridw:width - mod(width, ngrid);
y_ed = gridh:gridh:height - mod(height, ngrid);
feature = ones(ngrid*ngrid, 1);
for scanw=1:length(x_st)
    for scanh=1:length(y_st)                        
        maxresp = max(reshape(responsemap(y_st(scanh):y_ed(scanh), x_st(scanw):x_ed(scanw)), [1, (y_ed(scanh)-y_st(scanh)+1)*(x_ed(scanw)-x_st(scanw)+1)]));
        feature((scanh-1)*ngrid+scanw)=maxresp;
    end
end


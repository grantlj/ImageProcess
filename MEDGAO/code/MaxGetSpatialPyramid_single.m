function feature = MaxGetSpatialPyramid_single(responsemap, ngrid)
[height, width] = size(responsemap);                     %先看下responsemap的大小
gridw = floor((width - mod(width, ngrid)) / ngrid);     %确定一下格子的大小 width；
gridh = floor((height - mod(height, ngrid)) / ngrid);   %确定一下格子的大小 height;

x_st = 1:gridw:gridw*ngrid;                             %生成每个格子起始位置的绝对坐标：x
y_st = 1:gridh:gridh*ngrid;                             %生成每个格子起始位置的绝对坐标：y
x_ed = gridw:gridw:width - mod(width, ngrid);           %生成每个格子终止位置的绝对坐标：x
y_ed = gridh:gridh:height - mod(height, ngrid);         %生成每个格子终止位置的绝对坐标：y
%说白了就是每个格子的左上角和右下角的x y

feature = ones(ngrid*ngrid, 1);        %每个格子一列；（存response）
for scanw=1:length(x_st)
    for scanh=1:length(y_st)                        
        maxresp = max(reshape(responsemap(y_st(scanh):y_ed(scanh), x_st(scanw):x_ed(scanw)), [1, (y_ed(scanh)-y_st(scanh)+1)*(x_ed(scanw)-x_st(scanw)+1)]));  %找当前格子里这个feature的最大值；
        feature((scanh-1)*ngrid+scanw)=maxresp;   %存起来返回；
    end
end


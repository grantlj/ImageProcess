function feature = MaxGetSpatialPyramid_single(responsemap, ngrid)
[height, width] = size(responsemap);                     %�ȿ���responsemap�Ĵ�С
gridw = floor((width - mod(width, ngrid)) / ngrid);     %ȷ��һ�¸��ӵĴ�С width��
gridh = floor((height - mod(height, ngrid)) / ngrid);   %ȷ��һ�¸��ӵĴ�С height;

x_st = 1:gridw:gridw*ngrid;                             %����ÿ��������ʼλ�õľ������꣺x
y_st = 1:gridh:gridh*ngrid;                             %����ÿ��������ʼλ�õľ������꣺y
x_ed = gridw:gridw:width - mod(width, ngrid);           %����ÿ��������ֹλ�õľ������꣺x
y_ed = gridh:gridh:height - mod(height, ngrid);         %����ÿ��������ֹλ�õľ������꣺y
%˵���˾���ÿ�����ӵ����ϽǺ����½ǵ�x y

feature = ones(ngrid*ngrid, 1);        %ÿ������һ�У�����response��
for scanw=1:length(x_st)
    for scanh=1:length(y_st)                        
        maxresp = max(reshape(responsemap(y_st(scanh):y_ed(scanh), x_st(scanw):x_ed(scanw)), [1, (y_ed(scanh)-y_st(scanh)+1)*(x_ed(scanw)-x_st(scanw)+1)]));  %�ҵ�ǰ���������feature�����ֵ��
        feature((scanh-1)*ngrid+scanw)=maxresp;   %���������أ�
    end
end


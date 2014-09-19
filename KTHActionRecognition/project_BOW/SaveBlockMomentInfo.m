%对指定的avi,得到其指定帧的所有block的Moment信息
function [] = SaveBlockMomentInfo(path,filename,hufilename)
% path='running\';
% filename='person01_running_d4_uncomp.avi';
% hufilename='test.mat';

height=120;width=160;         %全部调整成120*160的尺寸
blockRow=24;blockCol=32;            %对每一帧分block用来计算humoment和bag-of-words模型
rowCount=round(height/blockRow);colCount=round(width/blockCol);

aviFile=[path,filename];
huFile=[path,hufilename];
MotionHistoryImageInfo=GetMotionHistoryInfo(aviFile);

huMat=zeros(1,7);

disp('     Calculating moments...');
for i=1:MotionHistoryImageInfo.retFrameCount
  for j=(i-1)*(rowCount*colCount)+1:i*(rowCount*colCount)
     now=MotionHistoryImageInfo.block(:,:,j);
    
     ret=GetHuMomentInfo(now);   %uint64*7   
     huMat=[huMat;ret];
  end
end
save(huFile,'huMat');

end


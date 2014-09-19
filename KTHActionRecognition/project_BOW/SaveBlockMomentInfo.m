%��ָ����avi,�õ���ָ��֡������block��Moment��Ϣ
function [] = SaveBlockMomentInfo(path,filename,hufilename)
% path='running\';
% filename='person01_running_d4_uncomp.avi';
% hufilename='test.mat';

height=120;width=160;         %ȫ��������120*160�ĳߴ�
blockRow=24;blockCol=32;            %��ÿһ֡��block��������humoment��bag-of-wordsģ��
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


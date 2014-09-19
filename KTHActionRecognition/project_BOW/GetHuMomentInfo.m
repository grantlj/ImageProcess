%返回所需的图像矩
function [ret]=GetHuMomentInfo(nowFrame)
  %nowFrame=imread('D:\Matlab\ImageProcess\KTHActionRecognition\project\17.jpg');
 % disp('    Calculating Moments...');
  nowFrame=normize(nowFrame);
  
 global avg_x;
 global avg_y;
 
 nowFrame=double(nowFrame);
 avg_x=round(getMomentIJ(nowFrame,1,0)/getMomentIJ(nowFrame,0,0));   %计算中心位置
 avg_y=round(getMomentIJ(nowFrame,0,1)/getMomentIJ(nowFrame,0,0));   %计算中心位置
  
  m20=getCentralMomentIJ(nowFrame,2,0);  m02=getCentralMomentIJ(nowFrame,0,2);
  m12=getCentralMomentIJ(nowFrame,1,2);  m21=getCentralMomentIJ(nowFrame,2,1);
  m30=getCentralMomentIJ(nowFrame,3,0);  m03=getCentralMomentIJ(nowFrame,0,3);
  m22=getCentralMomentIJ(nowFrame,2,2);
  
%  disp('    Finished Moments...');
  ret=[m20,m02,m12,m21,m22,m30,m03];
end

%归一化操作
function [nowFrame]=normize(nowFrame)
  [height,width]=size(nowFrame);
 
  nowFrame=double(nowFrame);
  maxVal=max(max(nowFrame));minVal=min(min(nowFrame));
  for i=1:height
      for j=1:width
          nowFrame(i,j)=250*(nowFrame(i,j)-minVal)/(maxVal-minVal);
      end
  end
 
  nowFrame=uint8(nowFrame);
  
end

%计算图像矩
function [moment]=getMomentIJ(nowFrame,pi,pj)
 moment=uint64(0);
  [height,width]=size(nowFrame);
  for i=1:height
      for j=1:width
          moment=moment+uint64((i^pi)*(j^pj)*nowFrame(i,j));
      end
  end
  

end

%计算图像中心矩
function [cmoment]=getCentralMomentIJ(nowFrame,pi,pj)
global avg_x;
global avg_y;

  cmoment=uint64(0);
  [height,width]=size(nowFrame);
  for i=1:height
      for j=1:width
          cmoment=cmoment+uint64(((i-avg_x)^pi)*((j-avg_y)^pj));
      end
  end
end
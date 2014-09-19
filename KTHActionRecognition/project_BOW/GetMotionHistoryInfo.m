
%生成每一个block的MHI图像
function [MotionHistoryImageInfo]=GetMotionHistoryInfo(destFile)

%disp(['Generating ',destFile,' MHI Pieces']);
                 

obj=VideoReader(destFile);  %得到的是一个object
vidFrames=read(obj);     %得到的是所有帧的数据
numFrames=obj.numberOfFrames;  %所有帧的数量
retFrameCount=round(numFrames/7); % 所有帧的数量/7作为采样数

%selectedFrame=round(linspace(2,numFrames,retFrameCount));


MotionHistoryImageInfo.retFrameCount=retFrameCount;

setHeight=120;setWidth=160;         %全部调整成120*160的尺寸
blockRow=24;blockCol=32;            %对每一帧分block用来计算humoment和bag-of-words模型

   for i=1:numFrames
      mov(i).cdata=vidFrames(:,:,:,i);                        %存每一帧的数据
      %mov_rgb(i)=mov(i);
      mov(i).cdata=rgb2gray(mov(i).cdata);          %转换成灰度
      mov(i).cdata=histeq(mov(i).cdata);
      mov(i).cdata=imresize(mov(i).cdata,[setHeight,setWidth]);
   end
  [height,width]=size(mov(1).cdata);                          %得到AVI文件大小
  
  H=uint8(zeros(height,width,numFrames));
  tau=250;decay=10;                                           %MHI中的 托 和 衰减参数
  
  disp('     Calculating MHI Information...');
% bg_info=getMeanBackground(mov,numFrames);                   %计算背景
% imwrite(bg_info.mu,'bg.jpg');
now=0;

avg_threshhold=0;                                               %使用所有帧的灰度均值来作为有效MHI的阈值
c=double(zeros(1,numFrames));

for i=2:numFrames
    %nowFrame=mov(i).cdata;
    %disp(['Now Frame:',num2str(i)]);
    nowFrame=mov(i).cdata-mov(i-1).cdata;                        %和背景做差
    
    for j=1:height
        for k=1:width
            ab=double(abs(nowFrame(j,k)));
            if  ((ab>35))    %大于一定的阈值 就认定为前景（运动的人）
                % if (abs(nowFrame(j,k))>0)
                nowFrame(j,k)=1;
                % disp(['Frame:',num2str(i),' j=',num2str(j),' k=',num2str(k),' sigma=',num2str(bg_info.sigma(j,k))]);
            else
                nowFrame(j,k)=0;
                
            end
        end
    end
    
    validPix=uint16(0);                                        %统计当前帧的有效点数
    for j=1:height
        for k=1:width
            if (nowFrame(j,k)==1)
                H(j,k,i)=tau;
                
            else
                try
                    H(j,k,i)=max(0,H(j,k,i-1)-decay);             %可能的背景，选择上一帧-衰减系数
                catch
                    H(j,k,i)=0;                                 %第一帧的情况，i-1=0会抛出异常，全部放0（黑）
                end
            end
            if (H(j,k,i)>=30)
                validPix=validPix+1;                           %灰度大于30，算作有效点
            end
            
        end
    end
    
   
    c(1,i)=double(double(validPix)/(height*width));              %计算有效点的比例
    avg_threshhold=avg_threshhold+c(1,i);
    
    
end

avg_threshhold=avg_threshhold/numFrames;                         %得到阈值

for i=2:numFrames
    if (c(1,i)>(avg_threshhold)*0.8)                               %大于80%的阈值：有效帧，可以用来做MHI
        %tmp=uint8(zeros(height,width));
        now=now+1;
        tmp=H(:,:,i);
        w2=fspecial('average',[2 2]);
        tmp=imfilter(tmp,w2);
        MotionHistoryImageInfo.image2(:,:,now)=tmp;
        % imwrite(MotionHistoryImageInfo.image(:,:,now),[num2str(now),'.jpg']);
    end
    
    if (now>=retFrameCount)                                        %已经生成到总帧数，可以退出
        break;
    end
    
end

if (now<retFrameCount)                                        %不够所需帧数，使用最后一帧补齐
    if (now~=0)
        for i=now+1:retFrameCount
            MotionHistoryImageInfo.image2(:,:,i)=MotionHistoryImageInfo.image2(:,:,now);
        end
    else
        for i=1:retFrameCount                                 %特殊情况，如果有效帧为0，这张avi全部放10
            for j=1:height
                for k=1:width
                    MotionHistoryImageInfo.image2(:,:,i)=10;
                end
            end
        end
    end
end  
    
  
  rowCount=round(height/blockRow);colCount=round(width/blockCol);
  
  for i=1:retFrameCount
    for j=1:rowCount
       for k=1:colCount
           %disp([num2str(i),',',num2str(j),',',num2str(k)]);
         %  try
             tmp=MotionHistoryImageInfo.image2((j-1)*blockRow+1:j*blockRow,(k-1)*blockCol+1:k*blockCol,i);
             MotionHistoryImageInfo.block(:,:,(i-1)*(rowCount*colCount)+(j-1)*rowCount+k)=tmp;
             %imwrite(tmp,[num2str((i-1)*(rowCount*colCount)+(j-1)*rowCount+k),'.jpg']);
%            catch
%                disp([num2str((j-1)*blockRow+1),',',num2str(j*blockRow),',',num2str((k-1)*blockCol+1),',',num2str(k*blockCol)]);
%                pause;
%            end
       end
    end
  end

disp('     Finished MHI pieces.');
  
end


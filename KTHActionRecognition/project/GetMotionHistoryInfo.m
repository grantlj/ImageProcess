
%得到MHI图像，返回帧数由retFrameCount确定
function [MotionHistoryImageInfo]=GetMotionHistoryInfo(destFile)

disp(['Generating ',destFile,' MHI Image']);
retFrameCount=15;                  

obj=VideoReader(destFile);  %得到的是一个object
vidFrames=read(obj);     %得到的是所有帧的数据
numFrames=obj.numberOfFrames;  %所有帧的数量

%selectedFrame=round(linspace(2,numFrames,retFrameCount));    %确定选哪几张MHI

%MotionHistoryImageInfo.selectedFrame=selectedFrame;
MotionHistoryImageInfo.retFrameCount=retFrameCount;


%disp(selectedFrame);

   for i=1:numFrames
      mov(i).cdata=vidFrames(:,:,:,i);                        %存每一帧的数据
      %mov_rgb(i)=mov(i);
      mov(i).cdata=rgb2gray(mov(i).cdata);          %转换成灰度
      mov(i).cdata=histeq(mov(i).cdata);
      %这里的灰度归一化操作效果不佳
      % mov(i).cdata=imadjust(mov(i).cdata,[],[0.1,0.9]);
      %  mov(i).cdata=imadjust(mov(i).cdata,[0.3,0.8],[0.2,0.5]);
      %mov(i).cdata=uint8(im2bw(mov(i).cdata,graythresh(mov(i).cdata)));
      %imwrite(mov(i).cdata,['origin',num2str(i),'.jpg']);
   end
  [height,width]=size(mov(1).cdata);                          %得到AVI文件大小
  
 % MotionHistoryImageInfo.image=uint8(zeros(selectedFrame,height,width));  %返回的MHI数据
 
   H=uint8(zeros(height,width,numFrames));
  tau=250;decay=10;                                           %MHI中的 托 和 衰减参数
  
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
       
    %se = strel('ball',10,8);
     %nowFrame=imopen(nowFrame,se);
     %imwrite(H(:,:,i),[num2str(i),'.jpg']);
     %nowFrame=nowFrame.*255;                             %255是白，0是黑，出来的第一张图理论上应该全黑，但是却全白?
     % imwrite(nowFrame,['RAW',num2str(i),'.jpg']);
      
       
     % disp(['Finish MHI of ',num2str(i),' Frame']);
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
     MotionHistoryImageInfo.image(:,:,now)=tmp;
    % imwrite(MotionHistoryImageInfo.image(:,:,now),[num2str(now),'.jpg']);
    end
     
   if (now>=retFrameCount)                                        %已经生成到总帧数，可以退出
         break;
   end
   
  end

    if (now<retFrameCount)                                        %不够所需帧数，使用最后一帧补齐
        if (now~=0)
              for i=now+1:retFrameCount
                  MotionHistoryImageInfo.image(:,:,i)=MotionHistoryImageInfo.image(:,:,now);
              end
        else
            for i=1:retFrameCount                                 %特殊情况，如果有效帧为0，这张avi全部放10
                for j=1:height
                    for k=1:width
                       MotionHistoryImageInfo.image(:,:,i)=10;
                    end
                end
            end
        end
        
            
    end
    
%     for i=1:retFrameCount
%         imwrite(MotionHistoryImageInfo.image(:,:,i),[num2str(i),'.jpg']);
%     end

 
 disp('MHI Finished...');
end


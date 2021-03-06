
function [ret] = GenerateTRARawInfo(destFile)
%返回某一视频文件在所有spatial下的trajectory描述子结构体
  spatial_size=8;
  spatial_cof=0.70;
  vl_setup;
  obj=VideoReader(destFile);  %得到的是一个object
  vidFrames=read(obj);     %得到的是所有帧的数据
  numFrames=obj.numberOfFrames;  %所有帧的数量
  ret=[];
  
  disp('*****Initialize Video...');
   for i=1:numFrames                                 
     mov(i).cdata=vidFrames(:,:,:,i);                                
     mov(i).cdata=rgb2gray(mov(i).cdata);                                
     mov(i).cdata=single(mov(i).cdata);  
   end
   
   [height0,width0]=size(mov(1).cdata);              %初始高度和宽度
   for i=1:spatial_size
     disp(['*******Handling spatial:',num2str(i)]);
     height=round(height0*spatial_cof^(i-1));width=round(width0*spatial_cof^(i-1));
    
     for j=1:numFrames
         mov(j).cdata=imresize(mov(j).cdata,[height,width]);
     end
     
     ofInfo=GetOpticalFlowInfo(mov);
     ret=[ret;GetTrajectory(mov,ofInfo)];
   end

end

%根据原视频和光流信息获取trajectory
function [traMat]=GetTrajectory(mov,ofInfo)
  traMat=[];
  gridSize=5;
  [height,width]=size(mov(1).cdata);
  
  pt_x=round(linspace(1,height,round(height/gridSize)+1));            %生成初始采样点垂直坐标
  pt_y=round(linspace(1,width,round(width/gridSize)+1));              %生成初始采样点水平坐标
  L=15;
  
  cood=zeros(size(pt_x,2),size(pt_y,2),L,2);                %记录每个点的15帧坐标:行号，列号，帧数，x和y
  
  %初始化，装入第一帧坐标
  for i=1:size(pt_x,2)
      for j=1:size(pt_y,2)
         cood(i,j,1,1)=pt_x(i);cood(i,j,1,2)=pt_y(j);
      end
  end
  
  p=1;
  
  for frameCount=1:size(ofInfo,2)-1
    u=ofInfo(frameCount).u;v=ofInfo(frameCount).v;
    p=p+1;
    
    for i=1:size(pt_x,2)
        for j=1:size(pt_y,2)
          cood(i,j,p,1)=cood(i,j,p-1,1)+v(i,j);       %垂直方向新位置
          cood(i,j,p,2)=cood(i,j,p-1,2)+u(i,j);       %水平方向新位置
%           %防止越界
%           cood(i,j,frameCount+1,1)=max(1,cood(i,j,frameCount+1,1));cood(i,j,frameCount+1,1)=min(height,cood(i,j,frameCount+1,1));
%           cood(i,j,frameCount+1,2)=max(1,cood(i,j,frameCount+1,2));cood(i,j,frameCount+1,2)=min(width,cood(i,j,frameCount+1,2));        
        end
    end
    if (mod(p,L)==0)
       %取满15帧了,首先我们要计算出特征vector T
   
       for i2=1:size(pt_x,2)
           for j2=1:size(pt_y,2)
               vec=zeros(1,(p-1)*2);
               sum=double(0);
               for k2=1:p-1
                   vec(1,2*k2-1)=cood(i2,j2,k2+1,1)-cood(i2,j2,k2,1);
                   vec(1,2*k2)=cood(i2,j2,k2+1,2)-cood(i2,j2,k2,2);
                   sum=sum+sqrt(vec(1,2*k2-1)^2+vec(1,2*k2)^2);
               end
               
               if (sum==0)
                   sum=1;
               end
               vec=vec./sum;
               traMat=[traMat;vec];
           end
       end
       
       %重新对cood进行初始化操作
          for i2=1:size(pt_x,2)
              for j2=1:size(pt_y,2)
                 cood(i2,j2,1,1)=pt_x(i2);cood(i2,j2,1,2)=pt_y(j2);
              end
          end
       p=1;
    end
  end
  

end

%获取光流信息。
function [ofInfo2]=GetOpticalFlowInfo(mov)

    %用于光流法检测的系统对象；
    hof=vision.OpticalFlow('ReferenceFrameDelay',1,'ReferenceFrameSource','Input port');
    hof.OutputValue='Horizontal and vertical components in complex form';
    ofInfo={};
    for i=1:size(mov,2)-1
        %这里一定要确保是single！
        frame=mov(i).cdata;
        frame_ref=mov(i+1).cdata;
        ofInfo{i} = step (hof,frame,frame_ref); %用光流法对视频中的每一帧图像进行处理,我们要的就是这个of 用complex的形式表明了每个点的转移速度
    end
     
    ofInfo{size(mov,2)}=ofInfo{size(mov,2)-1};
    for i=1:size(mov,2)
       tmp=ofInfo{i};
       u=real(tmp); v=imag(tmp);                                        %u为水平，v为垂直
       ofInfo2(i).u=medfilt2(u,[3,3]);ofInfo2(i).v=medfilt2(v,[3,3]);   %对optical flow进行中值滤波
    end
end


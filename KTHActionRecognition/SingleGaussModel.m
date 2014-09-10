function []=SingleGaussModel()
  destFile='D:\Matlab\ImageProcess\KTHActionRecognition\running\person01_running_d1_uncomp.avi';
  obj=VideoReader(destFile);  %得到的是一个object
  vidFrames=read(obj);     %得到的是所有帧的数据
  numFrames=obj.numberOfFrames;  %所有帧的数量
   for i=1:numFrames
      mov(i).cdata=vidFrames(:,:,:,i);
      mov_rgb(i)=mov(i);
      mov(i).cdata=rgb2gray(mov(i).cdata);
   end
  [height,width]=size(mov(1).cdata);
  pt_Row=40;pt_Col=100;                                                               %取20*50个特征点进行单高斯追踪
  pt_x=round(linspace(1,height,pt_Row)); pt_y=round(linspace(1,width,pt_Col));       %计算每一帧中的坐标
  
  LearnSet=round(numFrames*0.3);                                                     %初始条件选择前10%作为训练集
  
  sample=mov(321);
  for i=1:pt_Row
      for j=1:pt_Col
         sample.cdata(pt_x(i),pt_y(j),1)=255;
         sample.cdata(pt_x(i),pt_y(j),1)=255;
         sample.cdata(pt_x(i),pt_y(j),1)=255;
      end
  end
  imwrite(sample.cdata,'sample.jpg');
  
    for i=1:pt_Row
        for j=1:pt_Col
            data=[];
            param={};                                                                %记录高斯分布的2个参数
          for k=1:LearnSet
             data=[data;mov(k).cdata(pt_x(i),pt_y(j))];
          end
          [param.mu,param.sigma]=normfit(data);       
          DataMap(i,j).data=data;                                                    %实时记录前10个值
          ParamMap(i,j)=param;
        end
    end
    
    alpha=0.3;
    
    for i=LearnSet+1:numFrames
       
       count=0;
       for j=1:pt_Row
           for k=1:pt_Col
               nowVal=mov(i).cdata(pt_x(j),pt_y(k));
               flag=0;
               if (abs(nowVal-ParamMap(j,k).mu)>(2.5*ParamMap(j,k).sigma))
                   %这个点是非背景
                  count=count+1;
                  rec(count,1)=pt_x(j);rec(count,2)=pt_y(k);
                   flag=1;
               end
                if (flag==1) 
                    a2=0;
                else
                    a2=alpha;
                end
                %更新高斯模型参数
                %http://blog.csdn.net/carson2005/article/details/7607774
                  DataMap(j,k).data=[DataMap(j,k).data(2:LearnSet);nowVal];
                 % [param.mu,param.sigma]=normfit(DataMap(j,k).data);
                 mu=param.mu;
                 param.mu=(1-a2)*param.mu+a2*nowVal;
                 param.sigma=(1-a2)*param.sigma+a2*(nowVal-mu)*(nowVal-mu);
                 ParamMap(j,k)=param;
           end
       end
       
       %保存图像
%        r=zeros(height,width); g=zeros(height,width); b=zeros(height,width);
%        r=double(mov(i).cdata);g=double(mov(i).cdata);b=double(mov(i).cdata);
       
       for j=1:count
%           r(rec(count,1),rec(count,2))=255;
%           g(rec(count,1),rec(count,2))=0;
%           b(rec(count,1),rec(count,2))=0;

            mov_rgb(i).cdata(rec(j,1),rec(j,2),1)=255;
            mov_rgb(i).cdata(rec(j,1),rec(j,2),2)=255;
            mov_rgb(i).cdata(rec(j,1),rec(j,2),3)=255;
       end
       
       
     
       imwrite(mov_rgb(i).cdata,[num2str(i),'.jpg']);
        
    end
    
   %saveToAVI('result.avi',mov_rgb,numFrames);
   


  
end

% function saveToAVI(path,mov_rgb,numFrames)
%   aviobj = avifile(path);
%   aviobj.Quality = 100;
%   aviobj.compression='None';
% %使用addframe把图片写入视频
% for i=1:numFrames
%     picdata=mov_rgb(i).cdata;
%     picdata=im2uint8(mat2gray(picdata-255*i/100));
%     aviobj=addframe(aviobj,uint8(picdata));   
% end
% aviobj=close(aviobj);
% end
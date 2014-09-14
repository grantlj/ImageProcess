
%�õ�MHIͼ�񣬷���֡����retFrameCountȷ��
function [MotionHistoryImageInfo]=GetMotionHistoryInfo(destFile)

disp(['Generating ',destFile,' MHI Image']);
retFrameCount=15;                  

obj=VideoReader(destFile);  %�õ�����һ��object
vidFrames=read(obj);     %�õ���������֡������
numFrames=obj.numberOfFrames;  %����֡������

%selectedFrame=round(linspace(2,numFrames,retFrameCount));    %ȷ��ѡ�ļ���MHI

%MotionHistoryImageInfo.selectedFrame=selectedFrame;
MotionHistoryImageInfo.retFrameCount=retFrameCount;


%disp(selectedFrame);

   for i=1:numFrames
      mov(i).cdata=vidFrames(:,:,:,i);                        %��ÿһ֡������
      %mov_rgb(i)=mov(i);
      mov(i).cdata=rgb2gray(mov(i).cdata);          %ת���ɻҶ�
      mov(i).cdata=histeq(mov(i).cdata);
      %����ĻҶȹ�һ������Ч������
      % mov(i).cdata=imadjust(mov(i).cdata,[],[0.1,0.9]);
      %  mov(i).cdata=imadjust(mov(i).cdata,[0.3,0.8],[0.2,0.5]);
      %mov(i).cdata=uint8(im2bw(mov(i).cdata,graythresh(mov(i).cdata)));
      %imwrite(mov(i).cdata,['origin',num2str(i),'.jpg']);
   end
  [height,width]=size(mov(1).cdata);                          %�õ�AVI�ļ���С
  
 % MotionHistoryImageInfo.image=uint8(zeros(selectedFrame,height,width));  %���ص�MHI����
 
   H=uint8(zeros(height,width,numFrames));
  tau=250;decay=10;                                           %MHI�е� �� �� ˥������
  
 % bg_info=getMeanBackground(mov,numFrames);                   %���㱳��
 % imwrite(bg_info.mu,'bg.jpg');
  now=0;
  
  avg_threshhold=0;                                               %ʹ������֡�ĻҶȾ�ֵ����Ϊ��ЧMHI����ֵ
  c=double(zeros(1,numFrames));
  
  for i=2:numFrames
     %nowFrame=mov(i).cdata;
     %disp(['Now Frame:',num2str(i)]);
     nowFrame=mov(i).cdata-mov(i-1).cdata;                        %�ͱ�������
   
     for j=1:height
         for k=1:width
             ab=double(abs(nowFrame(j,k)));
           if  ((ab>35))    %����һ������ֵ ���϶�Ϊǰ�����˶����ˣ�
        % if (abs(nowFrame(j,k))>0)
               nowFrame(j,k)=1;
              % disp(['Frame:',num2str(i),' j=',num2str(j),' k=',num2str(k),' sigma=',num2str(bg_info.sigma(j,k))]);
           else
               nowFrame(j,k)=0;
            
           end   
         end
     end
      
       validPix=uint16(0);                                        %ͳ�Ƶ�ǰ֡����Ч����
       for j=1:height
           for k=1:width
       if (nowFrame(j,k)==1)                  
               H(j,k,i)=tau;  
              
           else
               try
                 H(j,k,i)=max(0,H(j,k,i-1)-decay);             %���ܵı�����ѡ����һ֡-˥��ϵ��
               catch
                   H(j,k,i)=0;                                 %��һ֡�������i-1=0���׳��쳣��ȫ����0���ڣ�
               end
       end
           if (H(j,k,i)>=30)
               validPix=validPix+1;                           %�Ҷȴ���30��������Ч��
           end
           
           end
       end
       
    %se = strel('ball',10,8);
     %nowFrame=imopen(nowFrame,se);
     %imwrite(H(:,:,i),[num2str(i),'.jpg']);
     %nowFrame=nowFrame.*255;                             %255�ǰף�0�Ǻڣ������ĵ�һ��ͼ������Ӧ��ȫ�ڣ�����ȴȫ��?
     % imwrite(nowFrame,['RAW',num2str(i),'.jpg']);
      
       
     % disp(['Finish MHI of ',num2str(i),' Frame']);
     c(1,i)=double(double(validPix)/(height*width));              %������Ч��ı���
     avg_threshhold=avg_threshhold+c(1,i);
     
   
  end
  
  avg_threshhold=avg_threshhold/numFrames;                         %�õ���ֵ
  
  for i=2:numFrames
    if (c(1,i)>(avg_threshhold)*0.8)                               %����80%����ֵ����Ч֡������������MHI
     %tmp=uint8(zeros(height,width));
     now=now+1;
     tmp=H(:,:,i);
     w2=fspecial('average',[2 2]);
     tmp=imfilter(tmp,w2); 
     MotionHistoryImageInfo.image(:,:,now)=tmp;
    % imwrite(MotionHistoryImageInfo.image(:,:,now),[num2str(now),'.jpg']);
    end
     
   if (now>=retFrameCount)                                        %�Ѿ����ɵ���֡���������˳�
         break;
   end
   
  end

    if (now<retFrameCount)                                        %��������֡����ʹ�����һ֡����
        if (now~=0)
              for i=now+1:retFrameCount
                  MotionHistoryImageInfo.image(:,:,i)=MotionHistoryImageInfo.image(:,:,now);
              end
        else
            for i=1:retFrameCount                                 %��������������Ч֡Ϊ0������aviȫ����10
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


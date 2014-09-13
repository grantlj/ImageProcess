%Ŀ�꣺����ÿһ֡��MHIͼ �˶�Ŀ��Ӧ����ʾ��ɫ��

function MotionHistoryImage()
  destFile='D:\Matlab\ImageProcess\KTHActionRecognition\walking\person01_walking_d4_uncomp.avi';
  obj=VideoReader(destFile);  %�õ�����һ��object
  vidFrames=read(obj);     %�õ���������֡������
  numFrames=obj.numberOfFrames;  %����֡������
   for i=1:numFrames
      mov(i).cdata=vidFrames(:,:,:,i);                        %��ÿһ֡������
      %mov_rgb(i)=mov(i);
      mov(i).cdata=rgb2gray(mov(i).cdata);          %ת���ɻҶ�
      mov(i).cdata=histeq(mov(i).cdata);
     % mov(i).cdata=imadjust(mov(i).cdata,[],[0.1,0.9]);
      %  mov(i).cdata=imadjust(mov(i).cdata,[0.3,0.8],[0.2,0.5]);
      %mov(i).cdata=uint8(im2bw(mov(i).cdata,graythresh(mov(i).cdata)));
      %imwrite(mov(i).cdata,['origin',num2str(i),'.jpg']);
   end
  [height,width]=size(mov(1).cdata);                          %�õ�AVI�ļ���С
   
  H=uint8(zeros(height,width,numFrames));
  tau=250;decay=10;                                           %MHI�е� �� �� ˥������
  
  bg_info=getMeanBackground(mov,numFrames);                   %���㱳��
  imwrite(bg_info.mu,'bg.jpg');
 
  for i=2:numFrames
     %nowFrame=mov(i).cdata;
    
     nowFrame=mov(i).cdata-mov(i-1).cdata;                        %�ͱ�������
   
     for j=1:height
         for k=1:width
             ab=double(abs(nowFrame(j,k)));
           if ((ab/5)>bg_info.sigma(j,k))    %����һ������ֵ ���϶�Ϊǰ�����˶����ˣ�
        % if (abs(nowFrame(j,k))>0)
               nowFrame(j,k)=1;
              % disp(['Frame:',num2str(i),' j=',num2str(j),' k=',num2str(k),' sigma=',num2str(bg_info.sigma(j,k))]);
           else
               nowFrame(j,k)=0;
            
           end   
         end
     end
      
       
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
       
           end
       end
       
        se=strel('diamond',5);
       nowFrame=imopen(nowFrame,se);
      imwrite(H(:,:,i),[num2str(i),'.jpg']);
      nowFrame=nowFrame.*255;                             %255�ǰף�0�Ǻڣ������ĵ�һ��ͼ������Ӧ��ȫ�ڣ�����ȴȫ��?
     % imwrite(nowFrame,['RAW',num2str(i),'.jpg']);
      
     % disp(['Finish MHI of ',num2str(i),' Frame']);
     
  end
  
  produceavifrompic('MHI.avi',H(:,:,1:numFrames),numFrames);
end

function [bg_info]=getMeanBackground(mov,numFrames)
 disp('Generating background...');
 [height,width]=size(mov(1).cdata);
 
 bg_info.mu=double(zeros(height,width));                                  %��ÿ����ǰ2%��֡����˹�ֲ�
 bg_info.sigma=double(zeros(height,width));
 
 par=0.2;
 for i=1:height
     for j=1:width
         data=[];
        % for k=1:round(par*numFrames)
          for k=1:round(par*numFrames)
           data=[data;mov(k).cdata(i,j)];
          end
         [bg_info.mu(i,j),bg_info.sigma(i,j)]=normfit(data);              %����ÿ����Ĳ���
     end
 end
 
 bg_info.mu=uint8(bg_info.mu);
 disp('Finish background...');
end


function produceavifrompic(path,phos,numFrames)
aviobj = avifile(path);
try
aviobj.Quality = 100;
aviobj.compression='None';
cola=0:1/255:1;
cola=[cola;cola;cola];%%�ڰ�ͼ��
cola=cola';
aviobj.colormap=cola;
for i=1:numFrames
    adata=phos(:,:,i);
    aviobj = addframe(aviobj,uint8(adata));
end
aviobj=close(aviobj);   
catch
     aviobj=close(aviobj);
end
end
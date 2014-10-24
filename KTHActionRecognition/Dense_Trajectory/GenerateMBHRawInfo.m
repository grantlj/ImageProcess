
function [ret] = GenerateMBHRawInfo(destFile)
%����ĳһ��Ƶ�ļ�������spatial�µ�trajectory�����ӽṹ��
  spatial_size=8;
  spatial_cof=0.70;
  vl_setup;
  obj=VideoReader(destFile);  %�õ�����һ��object
  vidFrames=read(obj);     %�õ���������֡������
  numFrames=obj.numberOfFrames;  %����֡������
  ret=[];
  
  disp('*****Initialize Video...');
   for i=1:numFrames                                 
     mov(i).cdata=vidFrames(:,:,:,i);                                
     mov(i).cdata=rgb2gray(mov(i).cdata);                                
     mov(i).cdata=single(mov(i).cdata);  
   end
   
   [height0,width0]=size(mov(1).cdata);              %��ʼ�߶ȺͿ��
   for i=1:spatial_size
     disp(['*******Handling spatial:',num2str(i)]);
     height=round(height0*spatial_cof^(i-1));width=round(width0*spatial_cof^(i-1));
    
     for j=1:numFrames
         mov(j).cdata=imresize(mov(j).cdata,[height,width]);
     end
     
     ofInfo=GetOpticalFlowInfo(mov);                           %��ȡ��ǰά�ȹ�����Ϣ;
     ret=[ret;GetMBH(mov,ofInfo)];                             %���ݵ�ǰά�ȹ�����Ϣ����ȡMBH��
   end
   
   %save(mbhfileInfo,'ret');
   

end

%����ԭ��Ƶ�͹�����Ϣ��ȡtrajectory��MBH
function [traMat]=GetMBH(mov,ofInfo)
  traMat=[];
  gridSize=5;
  [height,width]=size(mov(1).cdata);
  
  pt_x=round(linspace(1,height,round(height/gridSize)+1));            %���ɳ�ʼ�����㴹ֱ����
  pt_y=round(linspace(1,width,round(width/gridSize)+1));              %���ɳ�ʼ������ˮƽ����
  L=15;
  L0=L/3;
  
  cood=zeros(size(pt_x,2),size(pt_y,2),L,2);                %��¼ÿ�����15֡����:�кţ��кţ�֡����x��y
  pt_mbh=cell(size(pt_x,2),size(pt_y,2),L);                %��¼ÿ�����15֡��Ӧ��MBH��Ϣ  �кţ��кţ�֡����MBHx��MBHy�ѵ����       
  
  %��ʼ����װ���һ֡����
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
          cood(i,j,p,1)=cood(i,j,p-1,1)+v(i,j);       %��ֱ������λ��
          cood(i,j,p,2)=cood(i,j,p-1,2)+u(i,j);       %ˮƽ������λ��
%           ��ֹԽ��
          cood(i,j,p,1)=max(1,cood(i,j,p,1));cood(i,j,p,1)=min(height,cood(i,j,p,1));
          cood(i,j,p,2)=max(1,cood(i,j,p,2));cood(i,j,p,2)=min(width,cood(i,j,p,2));    
          
          %Selected Region Info.
          srInfo.l=floor(max(1,cood(i,j,p,2)-15));srInfo.r=floor(min(width,cood(i,j,p,2)+16));    %ȷ��region������λ��;
          srInfo.t=floor(max(1,cood(i,j,p,1)-15));srInfo.b=floor(min(height,cood(i,j,p,1)+16));   %ȷ��region������λ��;
          
          if ((srInfo.r-srInfo.l==31) && (srInfo.b-srInfo.t==31))          %ȷ��block��С�̶�Ϊ32*32
              region=u(srInfo.t:srInfo.b,srInfo.l:srInfo.r);               
              t1=GetBlockMBH(region);                           %����MBHx
              region=v(srInfo.t:srInfo.b,srInfo.l:srInfo.r);
              t2=GetBlockMBH(region);                           %����MBHy,Ȼ���MBHxƴ��һ��
              x_y=[t1,t2];
              pt_mbh{i,j,p}=x_y;
          else 
%               if (srInfo.l==1) srInfo.r=srInfo.l+30;end
%               if (srInfo.r==width) srInfo.l=srInfo.r-30;end
%               if (srInfo.t==1) srInfo.b=srInfo.t+30;end
%               if (srInfo.b==height) srInfo.t=srInfo.t-30; end
%               region=u(srInfo.t:srInfo.b,srInfo.l:srInfo.r);               
%               t1=GetBlockMBH(region);                           %����MBHx
%               region=v(srInfo.t:srInfo.b,srInfo.l:srInfo.r);
%               t2=GetBlockMBH(region);                           %����MBHy,Ȼ���MBHxƴ��һ��
%               x_y=[t1,t2];
%               pt_mbh{i,j,p}=x_y;
                pt_mbh{i,j,p}=zeros(1,64);
          end
        
        end
    end
    
    if (mod(p,L)==0)
       %ȡ��15֡��,��������Ҫ���������vector T
        for i2=1:size(pt_x,2)
          for j2=1:size(pt_y,2)
              vec=zeros(1,64);
              eigen=[];
              for s=2:L
                 %disp(pt_mbh{i,j,s});
                 q=pt_mbh{i2,j2,s};
                 vec=vec+q;
                 if (mod(s-1,L0)==0)        
                      eigen=[eigen,vec];
                      vec=zeros(1,64);
                 end
                     
              end
              traMat=[traMat;eigen];
          end       
        end
    
       %���¶�cood���г�ʼ������
          for i2=1:size(pt_x,2)
              for j2=1:size(pt_y,2)
                 cood(i2,j2,1,1)=pt_x(i2);cood(i2,j2,1,2)=pt_y(j2);
              end
          end
          
       p=1;
    end
  end
  traMat(all(traMat==0,2),:)=[]; 

end

function [blockMBH]=GetBlockMBH(region)
  region=abs(region);
  maxVal=max(max(region));
  minVal=min(min(region));
  region=uint8(floor(((region-minVal)./(maxVal-minVal))*255));
%  imshow(region);
  blockMBH=extractHOGFeatures(region,'CellSize',[16 16],'NumBins',8);
end

%��ȡ������Ϣ��
function [ofInfo2]=GetOpticalFlowInfo(mov)

    %���ڹ���������ϵͳ����
    hof=vision.OpticalFlow('ReferenceFrameDelay',1,'ReferenceFrameSource','Input port');
    hof.OutputValue='Horizontal and vertical components in complex form';
    ofInfo={};
    parfor i=1:size(mov,2)-1
        %����һ��Ҫȷ����single��
        frame=mov(i).cdata;
        frame_ref=mov(i+1).cdata;
        ofInfo{i} = step (hof,frame,frame_ref); %�ù���������Ƶ�е�ÿһ֡ͼ����д���,����Ҫ�ľ������of ��complex����ʽ������ÿ�����ת���ٶ�
    end
     
    ofInfo{size(mov,2)}=ofInfo{size(mov,2)-1};
    parfor i=1:size(mov,2)
       tmp=ofInfo{i};
       u=real(tmp); v=imag(tmp);                                        %uΪˮƽ��vΪ��ֱ
       ofInfo2(i).u=medfilt2(u,[3,3]);ofInfo2(i).v=medfilt2(v,[3,3]);   %��optical flow������ֵ�˲�
    end
end


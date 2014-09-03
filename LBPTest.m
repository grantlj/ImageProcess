function []=LBPTest()
  file_1='D:\MyClothes\basichouse_HMJP226C_04.jpg';
 % file_2='D:\MyClothes\basichouse_HMJP226C_06.jpg';
 file_2='D:\MyClothes\basichouse_HMJP226C_01.jpg';
  img1_origin=imread(file_1);
  img2_origin=imread(file_2);
  newSize=[480,320];
  blockSize=[60,40];
  
  colRowCount=newSize./blockSize;
  
  img1_origin=imresize(img1_origin,newSize);
  img2_origin=imresize(img2_origin,newSize);
  
  LBP1=getImageLBPHist(img1_origin,colRowCount,newSize,blockSize);
  LBP2=getImageLBPHist(img2_origin,colRowCount,newSize,blockSize);
  

  
  dist=double(0);
  for i=1:size(LBP1,2)
      dist=dist+(LBP1(1,i)-LBP2(1,i))^2;
  end
  dist=sqrt(dist);
  
  subplot(1,2,1);
  disp(dist);
  plot(LBP1);
  subplot(1,2,2);
  plot(LBP2);
end

function blockVector=getHistVector(imfile,m,n,blockSize,newSize)

  tmp=zeros(blockSize);
  blockVector=zeros(1,255);
  
  for i=(m-1)*blockSize(1)+2:m*blockSize(1)-1
      for j=(n-1)*blockSize(2)+2:n*blockSize(2)-1
          pow=0;sum=0;
          for k=i-1:i+1
              for l=j-1:j+1
                 if (imfile(k,l)>imfile(i,j))
                    if (k~=i || l~=j)
                        sum=sum+2^pow;
                    end
                 end
                
                if (k~=i || l~=j) pow=pow+1;end;
              end
          end
          tmp(i,j)=sum;  
          
          if (tmp(i,j)~=0)
            blockVector(tmp(i,j))=blockVector(tmp(i,j))+1;
          end
      end
  end
   
end

function LBP=getImageLBPHist(imfile,colRowCount,newSize,blockSize)
LBP=zeros(1,255);
for i=1:colRowCount(1)
      for j=1:colRowCount(2)
          blockVector=getHistVector(imfile,i,j,blockSize,newSize);
          LBP=[LBP,blockVector];
         % pause;
      end
end


end
function []=MyClothes_LBP_Comparer()


t = cd('D:\MyClothes\');                        % dos命令cd重置当前路径，自行设置，其下包含全部待处理文件

allnames = struct2cell(dir);   % dos命令dir列出所有的文件，用struct2cell转换为元胞数组

[m,n] = size(allnames);

fileInfo={};
for i= 3:n                           % 从3开始。前两个属于系统内部。
    name = allnames{1,i}         %  逐次取出文件名
    if (findstr(name,'.jpg')>=1)
        filename=[t,'\',name]        %   组成文件名
        fileInfo=[fileInfo;filename];
    end;
end
  newSize=[480,320];
  blockSize=[60,40];
 colRowCount=newSize./blockSize;

  file_1='D:\MyClothes\basichouse_HMJP226C_04.jpg';
  img1_origin=imread(file_1);
  img1_origin=imresize(img1_origin,newSize);
  LBP1=getImageLBPHist(img1_origin,colRowCount,newSize,blockSize);
 % file_2='D:\MyClothes\basichouse_HMJP226C_06.jpg';
 
 
allDist=double(zeros(1,size(fileInfo,1)));
fileInfo_sort=fileInfo;
clc;


 parfor p=1:size(fileInfo,1)
    disp(fileInfo(p));
    file_2=fileInfo{p};
    img2_origin=imread(file_2);

  img2_origin=imresize(img2_origin,newSize);

  LBP2=getImageLBPHist(img2_origin,colRowCount,newSize,blockSize);
  dist=double(0);
  for i=1:size(LBP1,2)
      dist=dist+(LBP1(1,i)-LBP2(1,i))^2;
  end
  allDist(p)=sqrt(dist);
end
  
%   subplot(1,2,1);
%   disp(dist);
%   plot(LBP1);
%   subplot(1,2,2);
%   plot(LBP2);

  disp('Complete calc...LBP');
  for i=1:size(fileInfo,1)-1
      for j=i+1:size(fileInfo,1)
          if (allDist(j)<allDist(i))
              t=allDist(j);allDist(j)=allDist(i);allDist(i)=t;
              t2=fileInfo_sort(j);fileInfo_sort(j)=fileInfo_sort(i);fileInfo_sort(i)=t2;
          end
      end
  end
  
  disp(fileInfo_sort);
  
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
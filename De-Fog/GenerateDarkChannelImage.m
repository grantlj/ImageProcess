function [] = GenerateDarkChannelImage()
  filename='test2.png';
  I_origin=imread(filename);
  I_origin=double(I_origin)/255;      %normalization
  [height,width,ch]=size(I_origin);   %get size and channel
  I_min=zeros(height,width);          %save "min" image
  
  radius=7;                           %filter radius
  windowSize=2*radius+1;
  
  for i=1:height
      for j=1:width
          I_min(i,j)=min(I_origin(i,j,:));
      end
  end
  
  J_dark=ordfilt2(I_min,1,ones(windowSize,windowSize));   %min-value Filter
  imshow(J_dark);
  
  %Select top 0.1% brightness point from J_dark.
  %Calculate A value;
  
end


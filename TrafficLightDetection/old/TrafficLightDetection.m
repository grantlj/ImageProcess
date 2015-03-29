function [ output_args ] = TrafficLightDetection()
  close all;
  im=imread('D:\light2.jpg');
  im_norm_rgb=convert_to_norm_rgb(im);
  
  figure;
  subplot(2,1,1);
  imshow(im);
  subplot(2,1,2);
  imshow(im_norm_rgb);
  figure;
  
  cand_region=extract_candidate_region(im_norm_rgb);
  imshow(cand_region);
  
  figure;
  
  im_edge=extract_edge(cand_region);
  subplot(1,3,1);
  imshow(im_edge(:,:,1));
  subplot(1,3,2);
  imshow(im_edge(:,:,2));
  subplot(1,3,3);
  imshow(im_edge(:,:,3));
  
 step_r=floor(min(size(im_edge(:,:,1)))*0.01);
 step_angle=2*pi/8;
 r_min=floor(min(size(im_edge(:,:,1)))*0.08);
 r_max=floor(min(size(im_edge(:,:,1)))*0.20);
  
  figure;
  imshow(im);
  hold on;
  
  for colorspace=1:3
     [hough_space,hough_circle,para]=do_hough_circle(im_edge(:,:,colorspace),step_r,step_angle,r_min,r_max,0.9);
      for i=1:size(para,1)
        plotcircle(para(i,:),colorspace);
        hold on;
      end
  end
  
 % imshow(hough_circle);
  
end

function []=plotcircle(para,colorspace)
  switch colorspace
      case 1
          color='r';   %red 
      case 2
           color='b';  %green
      case 3
          color='m';   %orange
  end
  
  sita=0:pi/20:2*pi;
  x0=para(1,2);y0=para(1,1);r=para(1,3);
  %%%%%%%%%%%%%%%%%%%%%%画圆%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot(r*cos(sita),r*sin(sita)); %中心点在原点，半径为r的圆
  plot(x0+r*cos(sita),y0+r*sin(sita),'Color',color);%中心点在（x0,y0）半径为rd的圆
  
end

%edge detect in each color space, and dilate operation.
function [im_edge]=extract_edge(im)
B=[0 1 0;
   1 1 1;
   0 1 0];

im_edge(:,:,1)=edge(im(:,:,1),'sobel'); im_edge(:,:,1)=imdilate(im_edge(:,:,1),B);  
im_edge(:,:,2)=edge(im(:,:,2),'sobel'); im_edge(:,:,2)=imdilate(im_edge(:,:,2),B);
im_edge(:,:,3)=edge(im(:,:,3),'sobel'); im_edge(:,:,3)=imdilate(im_edge(:,:,3),B);
end

%extract candidate region by normalized RGB.
function [cand_region]=extract_candidate_region(im)
  cand_region=zeros(size(im));
  r=im(:,:,1);g=im(:,:,2);b=im(:,:,3);
   for i=1:size(im,1)
      for j=1:size(im,2)
       %  r=im(i,j,1);g=im(i,j,2);b=im(i,j,3);
         if (r(i,j)>200 && g(i,j)<150 && b(i,j)<150)     %is red
            cand_region(i,j,:)=[255,0,0];
         end
         
         if (r(i,j)>200 && g(i,j)>150 && b(i,j)<150)    %is orange
           cand_region(i,j,:)=[0,0,255];
         end
         
         if (r(i,j)<150 && g(i,j)>240 && b(i,j)>220)   % is green
             cand_region(i,j,:)=[0,255,0];
         end
         
      end
  end

end


%convert rgb to normalized rgb.
function [im_norm_rgb]=convert_to_norm_rgb(im)
  im_norm_rgb=double(zeros(size(im)));
  for i=1:size(im,1)
      for j=1:size(im,2)
          s=double(im(i,j,1)+im(i,j,2)+im(i,j,3));
          if (s==0)
             im_norm_rgb(i,j,1)=0;im_norm_rgb(i,j,2)=0;im_norm_rgb(i,j,3)=0;
          else
             im_norm_rgb(i,j,1)=im(i,j,1)/s; im_norm_rgb(i,j,2)=im(i,j,2)/s; im_norm_rgb(i,j,3)=im(i,j,3)/s;
          end
      end
  end
 im_norm_rgb=im_norm_rgb*255;
end


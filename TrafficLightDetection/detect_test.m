impath='D:\dataset\TrafficLight\frame_006879.jpg';

load('frameInfo.mat');
dataset_path='D:/dataset/TrafficLight/';
%for frames=1:size(frameInfo,2)
for frames=7088:7160
    impath=[dataset_path,'frame_',sprintf('%06d',frames),'.jpg'];
  %   impath=[dataset_path,'frame_',sprintf('%06d',frameInfo{frames}.frame),'.jpg'];
    im_rgb=imread(impath);

    %%
    %Transfer RGB to LAB.
    %Channel 1: L Channel 2: A Channel 3: B
    %colorTransform = makecform('srgb2lab');
    %im_lab=double(applycform(im_rgb, colorTransform));
    %imshow(im_rgb);
    im_lab=RGB2Lab(im_rgb);

    %get rg, yb image.
    im_rg=im_lab(:,:,1).*im_lab(:,:,2);
    im_yb=im_lab(:,:,1).*im_lab(:,:,3); 
    %%
    %figure;

    %get rgyb image.
    im_rgyb=im_rg+im_yb; 
    im_saved=im_rgyb;
    %subplot(1,2,1);
    %imshow(im_rgyb,[]);

    %%
    %fill holes in rgyb image, respectively.
    for i=1:size(im_rgyb,1)
        for j=1:size(im_rgyb,2)
            if (im_rgyb(i,j)>0)
                im_rgyb_a(i,j)=im_rgyb(i,j);
            elseif (im_rgyb(i,j)~=0)
                im_rgyb_b(i,j)=im_rgyb(i,j);
            end
        end
    end

    im_rgyb_a=imfill(im_rgyb_a,4);
    im_rgyb_b=-imfill(-im_rgyb_b,4);

  %  im_rgyb=im_rgyb_a+im_rgyb_b;
    %subplot(1,2,2);
    %imshow(im_rgyb,[]);

    %%

    %using FRST algorithm to detect potential locations.
    % frst_ret=FRST(im_rgyb,6);
    % figure;
    % %imshow(frst_ret,[]);
    % [r,c] = nonmaxsuppts(frst_ret, 6,0.8*max(max(frst_ret)) );
    % 
    % bbox=[c r 6 6];
    % im_rgb = insertObjectAnnotation(im_rgb,'rectangle',bbox,'candidate');
    % imshow(im_rgb);
    %figure;
    for radii=[2 4 6 8 10]
       try
        frst_ret=FRST(im_rgyb_a,radii,0.05,3);
       [r c]=nonmaxsuppts(frst_ret,radii,0.85*(max(max(frst_ret))));

       for i=1:size(c,2)
         bbox=[c(i)-radii r(i)-radii radii*2 radii*2];
         im_rgb = insertObjectAnnotation(im_rgb,'rectangle',bbox,'candidate red');
       end
       
      % frst_ret=FRST(im_rgyb,radii,0.05,3);
     % im_rgby_b=-im_rgby_b;
      frst_ret=FRST(im_rgyb_b,radii,0.05,3);
      [r c]=nonmaxsuppts(frst_ret,radii,0.85*(max(max(frst_ret))));

       for i=1:size(c,2)
         bbox=[c(i)-radii r(i)-radii radii*2 radii*2];
         im_rgb = insertObjectAnnotation(im_rgb,'rectangle',bbox,'candidate green');
       end
       catch
       end
    end

    imshow(im_rgb);
end
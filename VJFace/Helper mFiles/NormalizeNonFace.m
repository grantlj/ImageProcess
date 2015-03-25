%B1 images
k = 1;
for i = 1:9
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B1_0000',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    for i = 10:99
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B1_000',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    for i = 100:559
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B1_00',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    
    %%B5 images
    for i = 0:9
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B5_0000',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    for i = 10:99
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B5_000',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    for i = 100:340
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B5_00',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end

    %B20 images
    for i = 1507:4305
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\B20_0',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    
    %geyser images
    for i = 1:227
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\geyser27_',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    
    %goldwater
    for i = 0:227
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\goldwater67_',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    
    %graves
    for i = 0:227
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\graves111_',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
    %GULF
    for i = 0:164
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\non-face\GULF_',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceNonFaces\',int2str(k),'.pgm');
        eval('imwrite(a,str);');
        k = k+1;
    end
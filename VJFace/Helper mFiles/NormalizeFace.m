    for i = 1:9
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\face\face0000',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceFaces\',int2str(i),'.pgm');
        eval('imwrite(a,str);');
    end
    for i=10:99
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\face\face000',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceFaces\',int2str(i),'.pgm');
        eval('imwrite(a,str);');
    end
    for i=100:999
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\face\face00',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceFaces\',int2str(i),'.pgm');
        eval('imwrite(a,str);');
    end
    for i=1000:2429
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\face\face0',int2str(i),'.pgm');
        eval('img=imread(str);');
        a = VarNorm(img);
        str = strcat('C:\Users\Juan\Desktop\School\Masters\Spring 2010\DIP\MIT CBCL Image set\train\VarianceFaces\',int2str(i),'.pgm');
        eval('imwrite(a,str);');
    end
    
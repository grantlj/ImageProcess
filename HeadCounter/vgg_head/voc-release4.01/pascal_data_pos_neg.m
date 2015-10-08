%function [pos] = pascal_data_pos(clspos,numTrainPos,cls)
function []=pascal_data_pos_neg()
cls='head'
%clspos为正样例文件的地址，numTrainPos正样例数目,cls为正样例的名称
% Get training data from the PASCAL dataset.
 pos = [];
 numpos = 0;
 %[a,b,c,d,e]=textread(clspos,'%d%d%d%d%s');
 posDir='D:/dataset/VOC2008/cache/pos/';
 numTrainPos=5340;
  for i = 1:numTrainPos;
      i
      numpos = numpos+1;
     % pos(numpos).im = [e(numpos)];
     % pos(numpos).x1 = a(numpos);
    %  pos(numpos).y1 = b(numpos);
     % pos(numpos).x2 = c(numpos);
     % pos(numpos).y2 = d(numpos);
      filepath=[posDir,'image_',sprintf('%04d',i),'.jpg'];
      pos(numpos).filepath=filepath;
      im=imread(filepath); [m,n,d]=size(im);
      pos(numpos).x1=1; pos(numpos).y1=1; pos(numpos).x2=m; pos(numpos).y2=n;
      pos(numpos).flip = false;
      pos(numpos).trunc = 0;
  end
  
   neg = [];
 numneg = 0;
 %[a,b,c,d,e]=textread(clspos,'%d%d%d%d%s');
 negDir='D:/dataset/VOC2008/cache/neg/';
 numTrainNeg=5163;
  for i = 1:numTrainNeg;
      i
      numneg = numneg+1;
     % pos(numpos).im = [e(numpos)];
     % pos(numpos).x1 = a(numpos);
    %  pos(numpos).y1 = b(numpos);
     % pos(numpos).x2 = c(numpos);
     % pos(numpos).y2 = d(numpos);
      filepath=[negDir,'image_',sprintf('%04d',i),'.jpg'];
      neg(numneg).filepath=filepath;
      neg(numneg).flip = false;
      
  end
  year = '2008';
 save(['D:/dataset/VOC2008/cache/',cls '_train_' year], 'pos','neg');
end  
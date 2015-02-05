function [] = semisupervised(viewsTr, viewsTest, U, labelTr, labelnp,logfilename)
%% 
% viewsTr{1} is m*n1
% viewsTest{1} is m*n2
% U is n*n
% labelTr is n1*c
% labelnp is n2*c
% where n1 is the size of training data, and n2 is the size of test data
% 

%%
tic;
[trainF, trainNum] = size(viewsTest{1});


%test by liujiang
% X1=viewsTr{1};X2=viewsTr{2};
%%

%% Get Laplacian Matrix L1 and L2
 para.lamda = 1;
 para.k =5;
%  [L1] = Laplacian_LRGA(X1, para);
%  [L2] = Laplacian_LRGA(X2, para);
%  Lrga{1}=L1;Lrga{2}=L2;
% save Laplacian_GK L1 L2;
% load Laplacian_GK;

disp('Calculating LRGA...');
for i=1:size(viewsTr,2)
   Lrga{i}=Laplacian_LRGA(viewsTr{i},para); 
end
disp('Finish LRGA...');

oneline = ones(trainNum,1);
% training

max_map=0;
% for r=-6:3:6
%     for alpha1=-6:3:6
%         for alpha2=-6:3:6
            r=0;alpha1=0;alpha2=0;
            disp(['calculating with parameter: r:',num2str(r),'   alpha1:',num2str(alpha1),'    alpha2:',num2str(alpha2)]);
            [w, b] = semiMultiViewGen(viewsTr, labelTr, U, 10^r, 10^alpha1, 10^alpha2, Lrga);
           %results = ((viewsTest{1}*w{1}+oneline*b{1}')+(viewsTest{2}*w{2}+oneline*b{2}'))/2;
            
            viewNum=size(viewsTest,2);
            results=[];
            for i=1:viewNum
              results=viewsTest{i}'*w{i}+oneline*b{i};
            end
            results=results/viewNum;
            
            map = evaluationMAP(labelnp, results);
            disp(['MAP=',num2str(map)]);
            
            %save to file.
            fid=fopen(logfilename,'w');
            fprintf(fid,'gamma=%d alpha=%d beta=%d\n',r,alpha1, alpha2);
            fprintf(fid,'mean:%d\n',mean(map));
            if mean(map)>max_map
               max_map=mean(map);
            end
            fprintf(fid,'%d ',map);
            fprintf(fid,'\n');
            fclose(fid);
%         end
%     end
% end

disp(['max_map=',num2str(max_map)]);
fid=fopen(logfilename,'w');
fprintf(fid,'%d ',max_map);
fprintf(fid,'\n');
fclose(fid);
toc;
end




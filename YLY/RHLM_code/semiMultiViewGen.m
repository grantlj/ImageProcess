function [f, feach, w, b] = semiMultiViewGen(views, labels, U, r, alpha1, alpha2, Lrga)

% views contains all the training data from different views.
% view1 and view2 should be m1*n, m2*n, labels should be n*c, where c is
% the number of clusters
% 
% labels is the training labels, the unlabeled data will be zero
% 
% U is a diagonal matrix, U(i,i) will be 1000000 if the data is labeled and 0
% views{1}=views{1}';
% views{2}=views{2}';
% viewNum = size(views,2);
viewNum=size(views,2);
% for i=1:viewNum
%   views{i}=views{i}';
% end
[trainF, trainNum] = size(views{1});

oneline = ones(trainNum,1);
eyemat = eye(trainNum);
% eyematm = eye(trainF);
lc = eyemat - (oneline*oneline')/trainNum;



%% ---------------------------------------------------------------- 
% get w1 and L1
temp = zeros(trainNum,trainNum);
% para.lamda = 1;
% para.k =5;
% Lrga{1} = Laplacian_LRGA(views{1}, para);
% Lrga{2} = Laplacian_LRGA(views{2}, para);

% temp = temp + eyemat / ( L{1}+alpha1* (eyemat -(views{1}')/(views{1}*views{1}' + r*eye(trainF))*views{1}) +alpha2*eyemat );
%% 
disp('Doing first For...');
for i=1:viewNum
    trainF = size(views{i}, 1);
    temp = temp + inv ( Lrga{i}+alpha1* (lc - lc*(views{i}')/(views{i}*lc*views{i}' + r*eye(trainF))*views{i}*lc) +alpha2*eyemat );
  % tmp3=alpha1* (lc - lc*(views{i}')/(views{i}*lc*views{i}' + r*eye(trainF))*views{i}*lc);
 %  tmp2=inv ( Lrga{i}+alpha1* (lc - lc*(views{i}')/(views{i}*lc*views{i}' + r*eye(trainF))*views{i}*lc) +alpha2*eyemat );
end

f =( viewNum*alpha2*eyemat + U - alpha2^2* temp )\(U*labels);
clear temp;
clear U;

disp('Finish first For...');
for i=1:viewNum
    disp(['Doing second for:',num2str(i)]);
    trainF = size(views{i}, 1);
    tmp=views{i}*lc*views{i}' + r*eye(trainF);
    feach{i} = alpha2* eyemat / ( Lrga{i} + alpha1* (lc - lc*(views{i}')/tmp*views{i}*lc)  + alpha2*eyemat ) * f;
    w{i} = eye(trainF) / tmp * views{i}*lc*feach{i};
    b{i} = (feach{i}'*oneline+w{i}'*views{i}*oneline)/trainNum;
    clear feach;
end
clear Lrga;
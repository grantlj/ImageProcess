function map= evaluationMAP(labelgt, results)

% labelgt is the groundtruth, and it is n*c
% results is the labeling results, it is n*c

thresh = 0.08;

[trainNum, classNum] = size(labelgt);

labelpos = find(labelgt>0);
% deal with groundtruth
for i=1:classNum
    labelgt2{i} = labelpos((labelpos<=i*trainNum) & (labelpos>(i-1)*trainNum));
    labelgt2{i} = labelgt2{i} - trainNum*(i-1);
% temp = poslabel((poslabel<=i*trainNum) & (poslabel>(i-1)*trainNum));
end



[value, idx] = sort(results, 'descend');
map = zeros(1,classNum);
% find the n labels in the results, calculate the precision and recall
for i=1:classNum
    rightNum=0;
    
    
    for j=1:trainNum
        flag = find(labelgt2{i}==idx(j,i));
        if flag>0
            rightNum = rightNum+1;
            map(1,i) = map(1,i) + rightNum/j;
        end
    end 
    map(1,i) = map(1,i)/length(labelgt2{i});
end
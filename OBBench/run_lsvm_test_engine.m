clear all;
clc;
acc=[];

t=dir('lsvm_model/');
modelcount=size(t,1)-3;
for i=0:modelcount
  acc(i+1)=lsvm_test_engine(i);
end

plot([1:modelcount],acc(2:modelcount+1));
hold on;
%plot([1:modelcount],acc(0)*ones(1,2:modelcount+1),'r');
line([1,modelcount+2],[acc(1),acc(1)],'Color','r','LineWidth',2)
max_ap=acc(1,1);
for i=2:50
  t=acc(1,i);  
  acc(1,i)=acc(1,103-i);
  acc(1,103-i)=t;
end

modelcount=100;
 figure;
 plot(1:modelcount,acc(2:modelcount+1));
 grid on;
 hold on;
   % axis([1,modelcount,0,1]);
%    plot(1:modelcount,acc(0)*ones(1,modelcount+1),'r');
line([1,modelcount+2],[acc(1),acc(1)],'Color','r','LineWidth',2); 
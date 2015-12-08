function [net,res,dldu,err]=gao_nn_update(content_feat,context_feat,img_labels,net,mode,lr,init_state)
%Update nn network.
%  1       10752           1          20
opts.weightDecay = 0.0005 ;
opts.momentum = 0.9 ;

batchSize=size(content_feat,1);
res=[];
res(1,1).x=do_format(content_feat);
res(1,2).x=do_format(context_feat);
res(1,3).x=do_format([content_feat,context_feat]);
for i=1:4
    for j=1:3
       l = net.layers{i,j} ;
       switch l.type
       case 'conv'
          res(i+1,j).x = vl_nnconv(res(i,j).x, l.filters, l.biases, 'pad', l.pad, 'stride', l.stride) ;
       case 'softmax'
          res(i+1,j).x = vl_nnsoftmax(res(i,j).x);  
       case 'normalize'
          res(i+1,j).x = vl_nnnormalize(res(i,j).x, l.param) ;
       case 'relu'
          res(i+1,j).x = vl_nnrelu(res(i,j).x) ;
          
       case 'sigmoid'
         res(i+1,j).x = vl_nnsigmoid(res(i,j).x) ;
       end
    end
end

%calculate our self-define regression result and loss function.
res(6,1).x=[];
err=0;
for i=1:batchSize
   qi=res(5,3).x(1,1,1,i);
   %qi
   if (init_state==1), qi=0.5;end;
   content_result=res(5,1).x(1,1,:,i);
   context_result=res(5,2).x(1,1,:,i);
   
   u=qi*context_result+(1-qi)*content_result;
   u=reshape(u,1,size(content_result,3));
   %pi_u=1/1+exp(-u);pi_u=reshape(pi_u,1,size(content_result,3));
   res(6,1).x(i,:)=u; %res(5,1).x is the resulted classification probability.
   [~,index]=max(1./(1+exp(-res(6,1).x(i,:))));
   if (index~=img_labels(i))
       err=err+1;
   end
end

%err=err/batchSize;
%1-err
%calculate loss function.
% dldu=0; dl_dcontent=0; dl_dcontext=0; dl_dq=0;

dldu=0; dl_dcontent=[]; dl_dcontext=[]; dl_dq=[];
for i=1:batchSize
  pi_u=1./(1+exp(-res(6,1).x(i,:)));
  y=zeros(1,size(content_result,3));y(1,img_labels(i))=1;  %construct y.
  dl_dq(1,1,1,i)=0;
  for j=1:size(y,2)
       dldu=dldu+( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j)))); 
       dl_dcontent(1,1,j,i)=( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j))))*(1-res(5,3).x(1,1,1,i));
       dl_dcontext(1,1,j,i)=( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j))))*(res(5,3).x(1,1,1,i));
       dl_dq(1,1,1,i)=dl_dq(1,1,1,i)+( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j))))*(res(5,2).x(1,1,j,i)-res(5,1).x(1,1,j,i));
%      dldu=dldu+( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j)))); 
%      dl_dcontent=dl_dcontent+( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j))))*(1-res(4,3).x(1,1,1,i));
%      dl_dcontext=dl_dcontext+( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j))))*(res(4,3).x(1,1,1,i));
%      dl_dq=dl_dq+( (y(1,j)/pi_u(1,j)-(1-y(1,j))/(1-pi_u(1,j)))*(pi_u(1,j)*(1-pi_u(1,j))))*(res(4,2).x(1,1,j,i)-res(4,1).x(1,1,j,i));
  end
end

err=err/batchSize;
1-err

dldu=-dldu./batchSize;
dl_dcontent=-dl_dcontent; dl_dcontext=-dl_dcontext;
dl_dq=-dl_dq./batchSize;
dl_dq(1,1,2,1:batchSize)=-dl_dq(1,1,1,1:batchSize);
if (mode==1)
   %start bp.
   res(5,1).dzdx=dl_dcontent;res(5,2).dzdx=dl_dcontext;res(5,3).dzdx=dl_dq;
   for j=1:3
       for i=4:-1:1
       
          l=net.layers{i,j};
          switch l.type
             case 'conv'
               [res(i,j).dzdx, res(i,j).dzdw{1}, res(i,j).dzdw{2}] = ...
                vl_nnconv(res(i,j).x, l.filters, l.biases, ...
                      res(i+1,j).dzdx, ...
                      'pad', l.pad, 'stride', l.stride) ;
             case 'softmax'
                res(i,j).dzdx = vl_nnsoftmax(res(i,j).x, res(i+1,j).dzdx) ;
              case 'normalize'
                res(i,j).dzdx = vl_nnnormalize(single(res(i,j).x), l.param, single(res(i+1,j).dzdx)) ;
             case 'relu'
                 res(i,j).dzdx = vl_nnrelu(res(i,j).x, res(i+1,j).dzdx) ;
          
             case 'sigmoid'
                res(i,j).dzdx = vl_nnsigmoid(res(i,j).x, res(i+1,j).dzdx) ;
          end
       end %end of j
   end %endo of i


 % gradient step
    for l=1:4
        for j=1:3
              if ~strcmp(net.layers{l,j}.type, 'conv'), continue ; end
             %disp([num2str(i),num2str(j)]);
              net.layers{l,j}.filtersMomentum = ...
                opts.momentum * net.layers{l,j}.filtersMomentum ...
                  - (lr * net.layers{l,j}.filtersLearningRate) * ...
                  (opts.weightDecay * net.layers{l,j}.filtersWeightDecay) * net.layers{l,j}.filters ...
                  - (lr * net.layers{l,j}.filtersLearningRate) / batchSize * res(l,j).dzdw{1} ;

              net.layers{l,j}.biasesMomentum = ...
                opts.momentum * net.layers{l,j}.biasesMomentum ...
                  - (lr * net.layers{l,j}.biasesLearningRate) * ....
                  (opts.weightDecay * net.layers{l,j}.biasesWeightDecay) * net.layers{l,j}.biases ...
                  - (lr * net.layers{l,j}.biasesLearningRate) / batchSize * res(l,j).dzdw{2} ;

              net.layers{l,j}.filters = net.layers{l,j}.filters + net.layers{l,j}.filtersMomentum ;
              net.layers{l,j}.biases = net.layers{l,j}.biases + net.layers{l,j}.biasesMomentum ;
        end
    end
end  
end

function [x]=do_format(feat)
  num_feat=size(feat,1); dim_feat=size(feat,2);
  x=zeros(1,dim_feat,1,num_feat);
  for i=1:num_feat
    x(1,:,1,i)=feat(i,:);  
  end
  x=single(x);
end


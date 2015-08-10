function [ output_args ] = gao_fusion_main()
vl_setupnn;

flower_count=6033;
batchSize=20;
epoches=150;
lr=0.005;


content_db_root_path='D:/dataset/birds/ZUO/feat_spp_object/';
context_db_root_path='D:/dataset/birds/ZUO/feat_spp_context/';
set_split_path='D:/dataset/birds/setid.mat';
label_path='D:/dataset/birds/imagelabels.mat';

%Define net blocks. 
%We have 3 layers. The first two layers consists of three individual fc
%components.
net.layers={};
scal=1;
init_bias=0.1;

%layer 1, part 1, fc layer for content net.
net.layers{1,1}= struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,10752,1,32,'single'),...
                           'biases', init_bias*ones(1,32,'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;

%layer 1, part 2, fc layer for context net.
net.layers{1,2}= struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,10752,1,32,'single'),...
                           'biases', init_bias*ones(1,32,'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;

%layer 1, part 3, fc layer for q output.
net.layers{1,3}=struct('type','conv',...
                       'filters', 0.01/scal * randn(1,10752*2,1,32,'single'),...
                       'biases', init_bias*ones(1,32,'single'), ...
                       'stride', 1, ...
                       'pad', 0, ...
                       'filtersLearningRate', 1, ...
                       'biasesLearningRate', 2, ...
                       'filtersWeightDecay', 1, ...
                       'biasesWeightDecay', 0) ;
                       

%layer 2, part 1, fc layer and softmax for content net.
net.layers{2,1}= struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,1,32,200,'single'),...
                           'biases', init_bias*ones(1,200,'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{3,1} = struct('type', 'normalize', ...
                           'param', [5 1 0.0001/5 0.75]) ;
net.layers{4,1}=struct('type','softmax');


%layer 2, part 2, fc layer and softmax for context net.
net.layers{2,2}= struct('type', 'conv', ...
                           'filters', 0.01/scal * randn(1,1,32,200,'single'),...
                           'biases', init_bias*ones(1,200,'single'), ...
                           'stride', 1, ...
                           'pad', 0, ...
                           'filtersLearningRate', 1, ...
                           'biasesLearningRate', 2, ...
                           'filtersWeightDecay', 1, ...
                           'biasesWeightDecay', 0) ;
net.layers{3,2} = struct('type', 'normalize', ...
   'param', [5 1 0.0001/5 0.75]) ;

net.layers{4,2}=struct('type','softmax');

%layer 3, part 3, q output.
% net.layers{2,3}= struct('type', 'conv', ...
%                            'filters', 0.01/scal * randn(1,1,32,1,'single'),...
%                            'biases', init_bias*ones(1,1,'single'), ...
%                            'stride', 1, ...
%                            'pad', 0, ...
%                            'filtersLearningRate', 1, ...
%                            'biasesLearningRate', 2, ...
%                            'filtersWeightDecay', 1, ...
%                            'biasesWeightDecay', 0) ;
                       
net.layers{2,3}= struct('type', 'conv', ...
   'filters', 0.01/scal * randn(1,1,32,2,'single'),...
   'biases', init_bias*ones(1,2,'single'), ...
   'stride', 1, ...
   'pad', 0, ...
   'filtersLearningRate', 1, ...
   'biasesLearningRate', 2, ...
   'filtersWeightDecay', 1, ...
   'biasesWeightDecay', 0) ;
                       
%net.layers{3,3} = struct('type', 'normalize', ...
%                           'param', [5 1 0.0001/5 0.75]) ;
net.layers{3,3}=struct('type','softmax');
net.layers{4,3}= struct('type', 'relu');


%layer 3, the final output layer.
net.layers{5,1}=struct('type','gao_define',...
                       'content_input',1,...
                       'context_input',2,...
                       'pooling_input',3);
                   
                   
% -------------------------------------------------------------------------
%                                                    Network initialization
% -------------------------------------------------------------------------

for i=1:4
    for j=1:3
      if ~strcmp(net.layers{i,j}.type,'conv'), continue; end
      net.layers{i,j}.filtersMomentum = zeros(size(net.layers{i,j}.filters), ...
        class(net.layers{i,j}.filters)) ;
      net.layers{i,j}.biasesMomentum = zeros(size(net.layers{i,j}.biases), ...
        class(net.layers{i,j}.biases)) ; %#ok<*ZEROLIKE>
      if ~isfield(net.layers{i,j}, 'filtersLearningRate')
        net.layers{i,j}.filtersLearningRate = 1 ;
      end
      if ~isfield(net.layers{i,j}, 'biasesLearningRate')
        net.layers{i,j}.biasesLearningRate = 1 ;
      end
      if ~isfield(net.layers{i,j}, 'filtersWeightDecay')
        net.layers{i,j}.filtersWeightDecay = 1 ;
      end
      if ~isfield(net.layers{i,j}, 'biasesWeightDecay')
        net.layers{i,j}.biasesWeightDecay = 1 ;
      end
    end
end
%%
[set labels]=get_set_split_info(flower_count,set_split_path,label_path);


%%
%Start to train.

dldu_list=[]; err_list=[];
for i=1:epoches
   filename=['model/net-epoch-',num2str(i),'.mat'];
   filename2=['model/net-epoch-',num2str(i+1),'.mat'];
   if (exist(filename,'file') && ~exist(filename2,'file') && i~=epoches)
       load(filename);load('train-info.mat');
       continue;
   elseif (exist(filename,'file'))
         continue;
   end
   %get training list for present epoch. 
   img_id=get_now_batch_id(set);
   total_rounds=ceil(size(img_id,2)/batchSize);
   
   dldu_tmp=0; err_tmp=0;
   for j=1:total_rounds
     
      disp(['Epoch: ',num2str(i),' Batch :',num2str(j),'/',num2str(total_rounds),'...']);
      
      %feed-forward & BP process. 
      sel_imgs=img_id((j-1)*batchSize+1:min(j*batchSize,size(img_id,2))); 
      [content_feat, context_feat, img_labels]=load_features(sel_imgs,content_db_root_path,context_db_root_path,labels);
      
      if (i==1 && j==1) init_state=1; else init_state=0; end
      [net,res,dldu,err]=gao_nn_update(content_feat,context_feat,img_labels,net,1,lr,init_state);
     % dldu
      dldu_tmp=dldu_tmp+dldu;
      err_tmp=err_tmp+err;
      
   end %
   
  
   save(filename,'net');
   dldu_list=[dldu_list,dldu_tmp/total_rounds]; err_list=[err_list,err_tmp/total_rounds];
   err_tmp
   save('train-info.mat','dldu_list','err_list');
   draw_figure(dldu_list,err_list); 
end

end





%%

function []=draw_figure(dldu_list,err_list)
  modelFigPath='model/fig.pdf';
  figure(1) ; clf ;
  subplot(1,2,1) ;
  epoch=size(dldu_list,2);
  semilogy(1:epoch, dldu_list, 'k') ; hold on ;
 % semilogy(1:epoch, info.val.objective, 'b') ;
  xlabel('training epoch') ; ylabel('dldu') ;
  grid on ;
  title('objective') ;
  subplot(1,2,2) ;
  
  plot(1:epoch, err_list, 'k') ; hold on ;
      
  grid on ;
  xlabel('training epoch') ; ylabel('error') ;
  title('error') ;
  drawnow ;
  print(1, modelFigPath, '-dpdf') ;

end


function [content_feat, context_feat, img_labels]=load_features(sel_imgs,content_db_root_path,context_db_root_path,labels)
  img_labels=labels(sel_imgs);
  content_feat=[];context_feat=[];
  for i=1:size(sel_imgs,2)
    now_img_content_path=[content_db_root_path,'image_',sprintf('%05d',sel_imgs(1,i)),'.mat'];  
    now_img_context_path=[context_db_root_path,'image_',sprintf('%05d',sel_imgs(1,i)),'.mat'];  
    
    %load content feat.
    load(now_img_content_path);
    content_feat=[content_feat;tmp_feat];
    
    %load context feat.
    load(now_img_context_path);
    context_feat=[context_feat;tmp_feat];
  end

end


function [img_id]=get_now_batch_id(set, batchSize)
  img_id=find(set==1);
  rand_indice=randperm(size(img_id,2));
  img_id=img_id(rand_indice);
end

%return the set split info.
function [set,labels]=get_set_split_info(flower_count,set_split_path,label_path)
   load(set_split_path);
   set=zeros(1,flower_count);
   for i=1:flower_count
       if (ismember(i,trnid))
         set(i)=1;
     elseif (ismember(i,valid))
         set(i)=1;
     else
         set(i)=3;
     end
   end
   
   load(label_path);
end
%%

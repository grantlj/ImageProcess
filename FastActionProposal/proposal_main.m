function [] = proposal_main(video_path,bdx_path,out_video_path)
%   video_path='test_02.avi';
%   bdx_path='test_02_bdx.mat';
%   out_video_path='test_02_out.avi';
  % video_path='test_39.avi';
  %bdx_path='test_39_bdx.mat';
  % out_video_path='test_39_out.avi';
  load(bdx_path);
  [frames,numFrames]=load_video(video_path);
  
  %select top K proposals.
  K=15; 
  
  %N is maximum candidate path.
  N=300;
  now_total=0;
  
  %top_n_pos is to store the last position (:,1) is frame, (:,2) is bbx.
  top_n_pos=zeros(N+1,2);
  %top_n_pos=[];
  %top_n_score is to store the scores.
  top_n_score=zeros(N+1,1);
  %top_n_score=[];
  %f array. f(t,i) the i-th total score in t-th frame.
  f=[];
  
  %tracker is the matrix to track back.
  tracker=[];
  %%
  for t=1:numFrames
     for i=1:feat_bdx{t}.total
        disp(['Frame t:',num2str(t),' has :',num2str(feat_bdx{t}.total)]);
       if (t==1)
           %the first frame, initialization.
           f(t,i)=feat_bdx{t}.score(i)./max(feat_bdx{t}.score(i));
           tracker(t,i)=0;
       else
           
           %dynamic programming here.
           maxscore=-inf; maxj=0;
           for j=1:feat_bdx{t-1}.total
              %validate two bounding boxes by eq.1 and eq.2
              if (validation_bdx(feat_bdx,t,i,j)==1)
                  score=f(t-1,j)+feat_bdx{t}.score(i)./max(feat_bdx{t}.score(i));
                  if (score<0)
                      score=0;
                  end
              else
                  score=-inf;
              end
              
              if (score>maxscore)
                  maxscore=score;
                  maxj=j;
              end
           
           end  %end of j
           
           %record the back-track and update the present f.
           tracker(t,i)=maxj;
           f(t,i)=maxscore;
           
           
           %now_total=now_total+1;
          % top_n_score=[top_n_score;f(t,i)];
           %top_n_pos=[top_n_pos;t,i];
           %update top-N f list.
           %no more just an insertion sort.
           for p=1:N+1
               if (f(t,i)>top_n_score(p,1))
                   break;
               end
           end
           
           if (p~=N+1)
               now_total=now_total+1;
               top_n_score=[top_n_score(1:p-1,:);f(t,i);top_n_score(p:N-1,:);0];
               top_n_pos=[top_n_pos(1:p-1,:);t,i;top_n_pos(p:N-1,:);0,0];
           end
               
       end %end of if
     end%end of i
  end%end of t;
  now_total=min(now_total,N);
  %[frames]=draw_result(frames,numFrames,now_total,top_n_score,top_n_pos,tracker,feat_bdx);
   
   %write_to_file(frames,out_video_path);
   
   'Raw proposal extracted, now generating final result...'
   
   %%
   %Next is the purify operation.
   
   %final_total, final_k_score, final_k_pos is similiar with 
   %the former one.
   final_total=0;
   final_k_score=[];
   final_k_pos=[];
   
   %bdx_union_table is to maintain the union result of each step.
   bdx_union_table=[];
   
   for k=1:K
     if (k==1)
         %the first one, just add the top one tracker.
         final_total=final_total+1;
         final_k_score=[final_k_score;top_n_score(1,:)];final_k_pos=[final_k_pos;top_n_pos(1,:)];
         
         %update the candidate pool, by deleting the Top-1.
         top_n_score=top_n_score(2:now_total,:);top_n_pos=top_n_pos(2:now_total,:);
         now_total=now_total-1;
         
         %update the union table.
         bdx_union_table=update_bdx_union_table(bdx_union_table,final_k_pos(1,:),tracker);
     else
         
         maxscore=-inf; maxj=0;maxbdx_union_table=[];
         for j=1:now_total
        
           %first check eq.5.  
           if (validation_path(final_k_pos,top_n_pos(j,:),tracker,feat_bdx)==1)
               %generate the temporary union table.
               tmp_union_table=update_bdx_union_table(bdx_union_table,top_n_pos(j,:),tracker);

               %calculate present score.
               tmp_score=get_score_of_bdx_set(tmp_union_table,feat_bdx);
           else
               tmp_score=-inf; %do not meet up the requirement of eq.5.
           end
           
           %compare with the present maximum score and update.
           if (tmp_score>maxscore)
               maxscore=tmp_score;maxj=j;maxbdx_union_table=tmp_union_table;
           end
           
         end %end of j
         
         if (maxscore==-inf) 
             break;
         else
            %update with path maxj;
            bdx_union_table=maxbdx_union_table;
            final_total=final_total+1;
            final_k_score=[final_k_score;top_n_score(maxj,:)];final_k_pos=[final_k_pos;top_n_pos(maxj,:)];
            %update the candidate pool, by deleting the Top-1.
            top_n_score=[top_n_score(1:maxj-1,:);top_n_score(maxj+1:now_total,:)];top_n_pos=[top_n_pos(1:maxj-1,:);top_n_pos(maxj+1:now_total,:)];    
            now_total=now_total-1;
         end
         
     end%end of if
   
   end%end of k
   
   [frames]=draw_result(frames,numFrames,final_total,final_k_score,final_k_pos,tracker,feat_bdx);
   write_to_file(frames,out_video_path);
end


%%
%calculate detailed path via posVec(the last frame) and tracker.
function [ppath]=calpath(posVec,tracker)
  ppath=[];
  now_frame_id=posVec(1,1);now_bdx_id=posVec(1,2);
  while (now_bdx_id~=0)
     %bdx_union_table=[bdx_union_table;now_frame_id,now_bdx_id];
     ppath=[ppath;now_frame_id,now_bdx_id];
     now_bdx_id=tracker(now_frame_id,now_bdx_id);
     now_frame_id=now_frame_id-1;
  end

end


%%
%valiadate the path by eq.5.
function [ret]=validation_path(final_k_pos, posVec,tracker,feat_bdx)
   ret=1;
   path_20=calpath(posVec,tracker);
   for i=1:size(final_k_pos,1)
     path_1=calpath(final_k_pos(i,:),tracker);
     path_2=path_20;
     %ensure that path_1 is ended earlier.
     
     if (path_1(1,1)>path_2(1,1))  %path_i(1,1) is the last frame cardinal of the path.
         tmp_path=path_1;path_1=path_2;path_2=tmp_path;
     end
    
     
     %obtain two pointer.
     p1=1; p2=path_2(1,1)-path_1(1,1)+1;
     
     area_intersection=0; area_union=0;
     while ( p1<=size(path_1,1) && p2<=size(path_2,1) && (path_1(p1,1)==path_2(p2,1)) )
       tmp_intersection=rectint(feat_bdx{path_1(p1,1)}.bounds(:,path_1(p1,2))', feat_bdx{path_2(p2,1)}.bounds(:,path_2(p2,2))');  
       area_intersection=area_intersection+tmp_intersection;
       
       w1=feat_bdx{path_1(p1,1)}.bounds(3,path_1(p1,2))';h1=feat_bdx{path_1(p1,1)}.bounds(4,path_1(p1,2))';
       w2=feat_bdx{path_2(p2,1)}.bounds(3,path_2(p2,2))';h2=feat_bdx{path_2(p2,1)}.bounds(4,path_2(p2,2))';
       
       area_union=area_union+w1*h1+w2*h2-tmp_intersection;
       
       p1=p1+1;p2=p2+1;
     end
     
     if (area_intersection/area_union>0.50)
         ret=0;
         break;
     end
   end
    
  
end


%%
%calculate present union set score.
function [score]=get_score_of_bdx_set(tmp_union_table,feat_bdx)
  score=0;
  for i=1:size(tmp_union_table,1)
     score=score+feat_bdx{tmp_union_table(i,1)}.score(tmp_union_table(i,2)); 
  end
end
%%
%update bdx union table.
function [bdx_union_table]=update_bdx_union_table(bdx_union_table,posVec,tracker)
  now_frame_id=posVec(1,1);now_bdx_id=posVec(1,2);
  while (now_bdx_id~=0)
     bdx_union_table=[bdx_union_table;now_frame_id,now_bdx_id];
     now_bdx_id=tracker(now_frame_id,now_bdx_id);
     now_frame_id=now_frame_id-1;
  end
  
  %unique the table!
  bdx_union_table=unique(bdx_union_table,'rows');

end
%%
function write_to_file(frames,out_video_path)
  obj=VideoWriter(out_video_path);
  obj.FrameRate=24;
  open(obj);
  for i=1:size(frames,2)
    writeVideo(obj,frames{i});
  end
  close(obj);
end
%%

function [full_frames]=draw_result(frames,numFrames,now_total,top_n_score,top_n_pos,tracker,feat_bdx)
%mkdir('out'); 
full_frames=frames;
for i=1:now_total
    %draw the i-dx proposal.
    now_frame_id=top_n_pos(i,1);now_bdx_id=top_n_pos(i,2);
    out_frames=frames;
    while (now_bdx_id~=0)
       now_frame=frames{1,now_frame_id};
       now_frame = insertObjectAnnotation(now_frame,'rectangle',feat_bdx{now_frame_id}.bounds(:,now_bdx_id)',i);
       out_frames{1,now_frame_id}=now_frame;
       
       now_frame_2=full_frames{1,now_frame_id};
       now_frame_2=insertObjectAnnotation(now_frame_2,'rectangle',feat_bdx{now_frame_id}.bounds(:,now_bdx_id)',i);
       full_frames{1,now_frame_id}=now_frame_2;
       
       
       now_bdx_id=tracker(now_frame_id,now_bdx_id);
       now_frame_id=now_frame_id-1;
    end
    
    
   % write_to_file(out_frames,['out/',num2str(i),'-th.avi']);
    
  end
end

%%
function [ret]=validation_bdx(feat_bdx,t,i,j)
  %   t-th frame the i-th bounding box.
  %   (t-1)-th frame the j-th bounding box.
  %overlapRatio = bboxOverlapRatio(bboxA,bboxB)
  overlapRatio=bboxOverlapRatio(feat_bdx{t-1}.bounds(:,j)',feat_bdx{t}.bounds(:,i)');
  hist1=feat_bdx{t-1}.colorhist(:,j)';
  hist2=feat_bdx{t}.colorhist(:,i)';
  hist=[hist1;hist2];
  
  color_sim=1-pdist(hist, 'cosine');
  
  if (overlapRatio>0.4 && color_sim>0.4)
      ret=1;
  else
      ret=0;
  end
  
end
%%
function [frames,numFrames]=load_video(video_path)
  obj=VideoReader(video_path);
  vidFrames=read(obj);
  numFrames=obj.numberOfFrames;
  frames={};
  for i=1:numFrames
      frames{i}=vidFrames(:,:,:,i);
  end
end
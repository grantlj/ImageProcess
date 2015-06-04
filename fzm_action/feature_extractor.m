function feature_extractor()
  raw_hog_path={'dataset/fzm_action/raw_hog/boxing/',...
                'dataset/fzm_action/raw_hog/handclapping/',...
                'dataset/fzm_action/raw_hog/handwaving/',...
                'dataset/fzm_action/raw_hog/normal/'};
            
  bow_path={'dataset/fzm_action/frame_bow/boxing/',...
            'dataset/fzm_action/frame_bow/handclapping/',...
            'dataset/fzm_action/frame_bow/handwaving/',...
            'dataset/fzm_action/frame_bow/normal/'};
      
  wordspath='dataset/fzm_action/words.txt';
  wordslist=generate_wordslist(wordspath);
  kdtree = vl_kdtreebuild(wordslist');
  
  save('dataset/fzm_action/words.mat','wordslist','kdtree');
  
  action_class_num=size(raw_hog_path,2);
  
  for action_class_count=1:action_class_num
    
    %get input/output path.
    input_path=raw_hog_path{action_class_count};
    output_path=bow_path{action_class_count};
    mkdir(output_path);
    filelist=get_raw_feature_path(input_path);
    
    for i=1:size(filelist,1)
      output_filename=[bow_path{action_class_count},num2str(i),'_feat_bow.mat'];
      if (~exist(output_filename,'file'))
        feat_bow=calculate_frame_bag_of_words(filelist{i},wordslist,kdtree);  
        save(output_filename,'feat_bow');
      else
          disp([output_filename,' already exist...']);
      end
    end
    
      
  end %end of action_class_count


end
%%
%calculate frame bag of words.
function [feat_bow]=calculate_frame_bag_of_words(filename,wordslist,kdtree)
   feat_list=generate_wordslist(filename);
   frames=size(feat_list,1)/1200;
   feat_bow=[];
   for i=1:frames
     disp(['Conducting bow on frame:',num2str(i)]);
     feat_bow=[feat_bow;calculate_bow_feat(feat_list((i-1)*1200+1:i*1200,:),wordslist,kdtree)];  
   end
end

function [frame_bow]=calculate_bow_feat(frame_feat,wordslist,kdtree)
  frame_bow=zeros(1,1000);
  for i=1:size(frame_feat,1)
     now_pt=frame_feat(i,:)';
     [index, distance] = vl_kdtreequery(kdtree, wordslist', now_pt);
     frame_bow(1,index)=frame_bow(1,index)+1;
  end

end

%%
function [wordslist]=generate_wordslist(wordspath)
  raw_mat=importdata(wordspath,'\r');
  size_info=regexp(raw_mat{1},' ','split');
  words_count=str2num(size_info{1}); words_dim=str2num(size_info{2});
  wordslist=zeros(words_count,words_dim);
  
  for i=2:words_count+1
     nowcell=raw_mat{i};
     nowcell_str_data=regexp(nowcell,' ','split');
     for j=1:words_dim
       wordslist(i-1,j)=str2num(nowcell_str_data{j});
     end
  end
 % wordslist=reshape(raw_mat,words_count,words_dim);
end
%%
%File I/O Part.
function [filelist]=get_raw_feature_path(input_path)
 root=(GetPresentPath);
 t=cd(input_path);
 
 allnames = struct2cell(dir);             % dos命令dir列出所有的文件，用struct2cell转换为元胞数组
 [m,n] = size(allnames);
 filelist={};
 for i= 3:n                                      % 从3开始。前两个属于系统内部。
     name = allnames{1,i}                         %  逐次取出文件名
     if ( (findstr(name,'.txt')>=1))
        filename=[input_path,name];                     %   组成文件名
        filelist=[filelist;filename];
       % hogfileInfo=[hogfileInfo;strrep(filename,'.avi','_HOG.mat')];
     end
 end
 
 
 t=cd(root); %back to root path.
end
function res=GetPresentPath()
clc;
p1=mfilename('fullpath');
disp(p1);
i=findstr(p1,'/');
if (isempty(i))         %Differ between Linux and Win
    i=findstr(p1,'\');
end
disp(i);
p1=p1(1:i(end));
res=p1;
end
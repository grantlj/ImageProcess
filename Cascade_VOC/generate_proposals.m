function [] = generate_proposals()
%Generate proposals for all datasets in PASCAL VOC 2012.
addpath(genpath('SelectiveSearchCodeIJCV\'));
VOCinit;

%Selective_Search_Proposal_Root_Path:
selective_search_proposal_root_path='Selective_Search_Proposals/';
%Start iterate classes.
for i=1:VOCopts.nclasses
  cls=VOCopts.classes{i};
  %gtids stores the id of image. recs stores all the information of the
  %image.
  [gtids,recs]=extract_training_set_info(VOCopts,cls);
  VOCopts_imgpath=VOCopts.imgpath;
  for j=1:length(gtids)
     %present image.
     boxes_path=[selective_search_proposal_root_path,gtids{j},'.mat'];
     if (~exist(boxes_path,'file'))
         im_path=sprintf(VOCopts_imgpath,gtids{j});
         disp(['Now handling class:',cls, ' image:',im_path]);
         im=imread(im_path); 
         [boxes]=generate_proposal_single_image(im);
         save(boxes_path,'boxes');
     end
  end
end

end

%%
%Load the image information.
function [gtids,recs]=extract_training_set_info(VOCopts,cls)

% load training set

cp=sprintf(VOCopts.annocachepath,VOCopts.trainset);
if exist(cp,'file')
    fprintf('%s: loading training set\n',cls);
    load(cp,'gtids','recs');
else
    tic;
    gtids=textread(sprintf(VOCopts.imgsetpath,VOCopts.trainset),'%s');
    for i=1:length(gtids)
        % display progress
        if toc>1
            fprintf('%s:  initializing trainset info: %d/%d\n',cls,i,length(gtids));
            %drawnow;
            tic;
        end

        % read annotation
        recs(i)=PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));
    end
    save(cp,'gtids','recs');
end

end
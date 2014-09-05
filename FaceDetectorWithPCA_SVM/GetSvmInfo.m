function [] = GetSvmInfo()
   nonfacePCAScoreDir='D:\Matlab\MitFace\nonfacePCAScore.dat'; %存储PCA评分后的脸
   facePCAScoreDir='D:\Matlab\MitFace\facePCAScore.dat'; %存储PCA评分后的脸
   SVMStructDir='D:\Matlab\Mitface\SVMStruct.mat';       %存储SVM分类器相关信息
   nonFaceInfo=load(nonfacePCAScoreDir);
   faceInfo=load(facePCAScoreDir);
   [nfRow,nfCol]=size(nonFaceInfo);
   [fRow,fCol]=size(faceInfo);
   Training=[nonFaceInfo;faceInfo];
   %Training=Training(:,1:10);
   tag=zeros(nfRow+fRow,1);
   for i=1:nfRow
       tag(i)=-1;
   end
   for i=nfRow+1:nfRow+fRow
       tag(i)=1;
   end
   SVMStruct=svmtrain(Training,tag,'Kernel_Function','polynomial','showplot',true);
   disp('Finish SVM calc....');
   save(SVMStructDir,'-struct','SVMStruct');
%    disp(SVMStruct);
%    for i=nfRow+1:nfRow+fRow
%      ans=svmclassify(SVMStruct,Training(i,:));
%      disp(ans);
%    end
end


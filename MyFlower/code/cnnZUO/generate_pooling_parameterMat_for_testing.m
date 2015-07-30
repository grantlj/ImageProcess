function [pooling_parameterMat] = generate_pooling_parameterMat_for_testing(test_feat_1,test_feat_2,thetaVec)
  pooling_parameterMat=zeros(size(test_feat_1,1),size(thetaVec,1));
   for i=1:size(test_feat_1,1)
     now_feat=[test_feat_1(i,:),test_feat_2(i,:)];
     for j=1:size(thetaVec,1)
       now_w=thetaVec(j,1:end-1);now_b=thetaVec(j,end);
       now_pooling_parameter=1/(1+exp(-(now_w*now_feat'+now_b)));
       pooling_parameterMat(i,j)=now_pooling_parameter;
     end
      
  end


end


function [] =FVTest()
vl_setup;
numFeatures = 5000 ;                                       %5000����������������words
dimension = 2 ;
data = rand(dimension,numFeatures) ;

numClusters = 30 ;
[means, covariances, priors] = vl_gmm(data, numClusters);  %Э������Ƿ��� ���Ƕ�ά�汾�ĸ�˹�ֲ���������������ϵ�������
                                                           %prior�����䵽ÿ�����ʱ���Χ�ڵĸ��ʣ�
numDataToBeEncoded = 2000;                                 %2000������������������ʾһ��ͼƬ����vl_fisher�Ժ󣬿���ֱ������һ��
                                                           %���Ⱥ�2000�޹صģ�ֻ��ѵ�����йص�fisher
                                                           %vector
                                                           %������������ͼƬ��ÿ��ͼƬ������ô����

dataToBeEncoded = rand(dimension,numDataToBeEncoded);
encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
end


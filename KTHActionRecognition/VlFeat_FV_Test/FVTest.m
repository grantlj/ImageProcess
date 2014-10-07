function [] =FVTest()
vl_setup;
numFeatures = 5000 ;                                       %5000个样本，用来生成words
dimension = 2 ;
data = rand(dimension,numFeatures) ;

numClusters = 30 ;
[means, covariances, priors] = vl_gmm(data, numClusters);  %协方差就是方差 就是二维版本的高斯分布里面的两个方向上的西格玛
                                                           %prior就是落到每个单词本范围内的概率？
numDataToBeEncoded = 2000;                                 %2000个特征，可以用来表示一个图片！用vl_fisher以后，可以直接生成一个
                                                           %长度和2000无关的，只和训练集有关的fisher
                                                           %vector
                                                           %用来描述整个图片（每个图片都是这么长）

dataToBeEncoded = rand(dimension,numDataToBeEncoded);
encoding = vl_fisher(dataToBeEncoded, means, covariances, priors);
end


 function varargout = gmm(X, K_or_centroids)
% ============================================================
% Expectation-Maximization iteration implementation of
% Gaussian Mixture Model.
%
% PX = GMM(X, K_OR_CENTROIDS)
% [PX MODEL] = GMM(X, K_OR_CENTROIDS)
%
%  - X: N-by-D data matrix.
%  - K_OR_CENTROIDS: either K indicating the number of
%       components or a K-by-D matrix indicating the
%       choosing of the initial K centroids.
%
%  - PX: N-by-K matrix indicating the probability of each
%       component generating each point.
%  - MODEL: a structure containing the parameters for a GMM:
%       MODEL.Miu: a K-by-D matrix.
%       MODEL.Sigma: a D-by-D-by-K matrix.
%       MODEL.Pi: a 1-by-K vector.
% ============================================================
 
    threshold = 1e-15;
    [N, D] = size(X);
 
    if isscalar(K_or_centroids)
        K = K_or_centroids;
        % randomly pick centroids
        rndp = randperm(N);
        centroids = X(rndp(1:K), :);
    else
        K = size(K_or_centroids, 1);
        centroids = K_or_centroids;
    end
 
    % initial values
    [pMiu pPi pSigma] = init_params(); %初始化
 
    Lprev = -inf; %inf表示正无究大，-inf表示为负无究大
    while true
        Px = calc_prob();
 
        % new value for pGamma
        pGamma = Px .* repmat(pPi, N, 1);
        pGamma = pGamma ./ repmat(sum(pGamma, 2), 1, K); %求每个样本由第K个聚类，也叫“component“生成的概率
 
        % new value for parameters of each Component
        Nk = sum(pGamma, 1);
        pMiu = diag(1./Nk) * pGamma' * X; %重新计算每个component的均值
        pPi = Nk/N; %更新混合高斯的加权系数
        for kk = 1:K %重新计算每个component的协方差
            Xshift = X-repmat(pMiu(kk, :), N, 1);
            pSigma(:, :, kk) = (Xshift' * ...
                (diag(pGamma(:, kk)) * Xshift)) / Nk(kk);
        end
 
        % check for convergence
        L = sum(log(Px*pPi')); %求混合高斯分布的似然函数
        if L-Lprev < threshold %随着迭代次数的增加，似然函数越来越大，直至不变
            break; %似然函数收敛则退出
        end
        Lprev = L;
    end
 
    if nargout == 1 %如果返回是一个参数的话，那么varargout=Px;
        varargout = {Px};
    else %否则，返回[Px model],其中model是结构体
        model = [];
        model.Miu = pMiu;
        model.Sigma = pSigma;
        model.Pi = pPi;
        varargout = {Px, model};
    end
 
    function [pMiu pPi pSigma] = init_params()
        pMiu = centroids;
        pPi = zeros(1, K);
        pSigma = zeros(D, D, K);
 
        % hard assign x to each centroids
        distmat = repmat(sum(X.*X, 2), 1, K) + ... %distmat第j行的第i个元素表示第j个数据与第i个聚类点的距离，如果数据有4个，聚类2个，那么distmat就是4*2矩阵
            repmat(sum(pMiu.*pMiu, 2)', N, 1) - 2*X*pMiu'; %sum(A，2)结果为列向量，第i个元素是第i行的求和
        [dummy labels] = min(distmat, [], 2); %返回列向量dummy和labels，dummy向量记录distmat的每行的最小值，labels向量记录每行最小值的列号，即是第几个聚类，labels是N×1列向量，N为样本数
 
        for k=1:K
            Xk = X(labels == k, :); %把标志为同一个聚类的样本组合起来
            pPi(k) = size(Xk, 1)/N; %求混合高斯模型的加权系数，pPi为1*K的向量
            pSigma(:, :, k) = cov(Xk); %分别求单个高斯模型或聚类样本的协方差矩阵,pSigma为D*D*K的矩阵
        end
    end
 
    function Px = calc_prob()
        Px = zeros(N, K);
        for k = 1:K
            Xshift = X-repmat(pMiu(k, :), N, 1); %Xshift表示为样本矩阵-Uk，第i行表示xi-uk
            inv_pSigma = inv(pSigma(:, :, k)); %求协方差的逆
            tmp = sum((Xshift*inv_pSigma) .* Xshift, 2); %tmp为N*1矩阵，第i行表示（xi-uk)^T*Sigma^-1*(xi-uk)
            coef = (2*pi)^(-D/2) * sqrt(det(inv_pSigma)); %求多维正态分布中指数前面的系数
            Px(:, k) = coef * exp(-0.5*tmp); %求单独一个正态分布生成样本的概率或贡献
        end
    end
end


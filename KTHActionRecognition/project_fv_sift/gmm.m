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
    [pMiu pPi pSigma] = init_params(); %��ʼ��
 
    Lprev = -inf; %inf��ʾ���޾���-inf��ʾΪ���޾���
    while true
        Px = calc_prob();
 
        % new value for pGamma
        pGamma = Px .* repmat(pPi, N, 1);
        pGamma = pGamma ./ repmat(sum(pGamma, 2), 1, K); %��ÿ�������ɵ�K�����࣬Ҳ�С�component�����ɵĸ���
 
        % new value for parameters of each Component
        Nk = sum(pGamma, 1);
        pMiu = diag(1./Nk) * pGamma' * X; %���¼���ÿ��component�ľ�ֵ
        pPi = Nk/N; %���»�ϸ�˹�ļ�Ȩϵ��
        for kk = 1:K %���¼���ÿ��component��Э����
            Xshift = X-repmat(pMiu(kk, :), N, 1);
            pSigma(:, :, kk) = (Xshift' * ...
                (diag(pGamma(:, kk)) * Xshift)) / Nk(kk);
        end
 
        % check for convergence
        L = sum(log(Px*pPi')); %���ϸ�˹�ֲ�����Ȼ����
        if L-Lprev < threshold %���ŵ������������ӣ���Ȼ����Խ��Խ��ֱ������
            break; %��Ȼ�����������˳�
        end
        Lprev = L;
    end
 
    if nargout == 1 %���������һ�������Ļ�����ôvarargout=Px;
        varargout = {Px};
    else %���򣬷���[Px model],����model�ǽṹ��
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
        distmat = repmat(sum(X.*X, 2), 1, K) + ... %distmat��j�еĵ�i��Ԫ�ر�ʾ��j���������i�������ľ��룬���������4��������2������ôdistmat����4*2����
            repmat(sum(pMiu.*pMiu, 2)', N, 1) - 2*X*pMiu'; %sum(A��2)���Ϊ����������i��Ԫ���ǵ�i�е����
        [dummy labels] = min(distmat, [], 2); %����������dummy��labels��dummy������¼distmat��ÿ�е���Сֵ��labels������¼ÿ����Сֵ���кţ����ǵڼ������࣬labels��N��1��������NΪ������
 
        for k=1:K
            Xk = X(labels == k, :); %�ѱ�־Ϊͬһ������������������
            pPi(k) = size(Xk, 1)/N; %���ϸ�˹ģ�͵ļ�Ȩϵ����pPiΪ1*K������
            pSigma(:, :, k) = cov(Xk); %�ֱ��󵥸���˹ģ�ͻ����������Э�������,pSigmaΪD*D*K�ľ���
        end
    end
 
    function Px = calc_prob()
        Px = zeros(N, K);
        for k = 1:K
            Xshift = X-repmat(pMiu(k, :), N, 1); %Xshift��ʾΪ��������-Uk����i�б�ʾxi-uk
            inv_pSigma = inv(pSigma(:, :, k)); %��Э�������
            tmp = sum((Xshift*inv_pSigma) .* Xshift, 2); %tmpΪN*1���󣬵�i�б�ʾ��xi-uk)^T*Sigma^-1*(xi-uk)
            coef = (2*pi)^(-D/2) * sqrt(det(inv_pSigma)); %���ά��̬�ֲ���ָ��ǰ���ϵ��
            Px(:, k) = coef * exp(-0.5*tmp); %�󵥶�һ����̬�ֲ����������ĸ��ʻ���
        end
    end
end


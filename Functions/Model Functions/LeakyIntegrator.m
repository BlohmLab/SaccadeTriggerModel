function [ EstimateK1 ] = LeakyIntegrator( xi, EstimateK, tau )
%LeakyIntegrator Estimate(k) = alp*Estimate + (1-alp)*xi
% J Coutinho (2017)

%   Leaky integration function

alp = 1 - 1/tau;
% EstimateK1 = alp.*EstimateK + (1-alp).*xi;

EstimateK1 = EstimateK + (1./tau).*(xi-EstimateK);

end


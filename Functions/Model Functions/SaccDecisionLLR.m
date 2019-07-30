function [ pSaccRK1, pSaccLK1, logPsaccR, logPsaccL] = SaccDecisionLLR(PEpred, sigPEpred, pSaccR, pSaccL, DecisionParams )
%SaccTrigger Fn: PEpred --> Psacc(R,L), LLRsacc(R,L)
% J Coutinho (2017)


%   First Calculate PE extrapolation using PE, RS
%   Calculate variance of extrapolation
%   Use mean and var to compute P(sacc) using cdf

% delT = 0.125;   %constant duration prediction (in s)
% peT = 0.5;
% alp = 0.95;


% PEtr = PEsens + RSbest.*delT;
% SigTrig = sigPEsens + (delT.^2)*sigRSbest;

peT = DecisionParams.peThresh;
tau = DecisionParams.decisionTau;
decisionNoise = DecisionParams.decisionNoise;

pSaccRi = 1 - normcdf(peT, PEpred, sqrt(sigPEpred));
pSaccLi = normcdf(-peT, PEpred, sqrt(sigPEpred));

pSaccRK1 = LeakyIntegrator( pSaccRi, pSaccR, tau);
pSaccLK1  = LeakyIntegrator( pSaccLi, pSaccL, tau);

logPsaccR = log(pSaccRK1) - log(pSaccLK1) + decisionNoise*randn;
logPsaccL = log(pSaccLK1) - log(pSaccRK1) + decisionNoise*randn;

end


function [ PEpred, sigPEpred ] = PEpredict( PEsens, sigPEsens, RSbest, sigRSbest, delT )
%PEpredict Uses RS to extrapolate PE by delT seconds
%   (also calculates sigPEpred)
% J Coutinho (2017)

PEpred = PEsens + RSbest.*delT;
sigPEpred = sigPEsens + (delT.^2).*sigRSbest;

end


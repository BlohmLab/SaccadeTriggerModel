function [ RSpred, sigRSpred ] = RSpredict( RSsens, sigRSsens, RAsens, sigRAsens, delT )
%PEpredict Uses RA to extrapolate RS by delT seconds
%   (also calculates sigRSpred)
% J Coutinho (2017)

RSpred = RSsens + RAsens.*delT;
sigRSpred = sigRSsens + (delT.^2)*sigRAsens;

end


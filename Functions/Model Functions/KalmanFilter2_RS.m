function [ RSsensK1, sigRSsensK1, K, RSobs ] = KalmanFilter2_RS(RSdelay, RSsens, sigRSsens, params)
%RS_Kalman_Filter
% J Coutinho (2017)

%   Provides a noisy sensory value for RS from RSdet,
%   RSdet has delay already incorporated
%   Makes RS estimate (RSk1, RSsigK1)from RSobs and past RS estimate (RSk, RSsigK)
%   Sig is a Variance, not standard deviation.

% (_EA): now includes Eye accel in update step for RS.
% dt = 0.001;

if isstruct(params)
    D = params.RS.D;
    R = params.RS.R;
    Q = params.RS.Q;
    Omn = params.RS.Omn;
elseif isnumeric(params)
    if length(params) == 4
        D = params(1);
        R = params(2);
        Q = params(3);
        Omn = params(4);
    else
        fprintf('length of numeric param vector does not match number of parameters needed to be specified \n See comments for help \n')
    end
end



if nargin<4
    D = 1;     % multiplicative noise
    
    R = 10;     % additive noise
    
    Q = 1;     % Expected change in RS in generative model
    
    Omn = 0.3;  %Internal Process noise
end

RSobs = (1 + D*randn)*RSdelay + R*randn;

K = sigRSsens / (sigRSsens + R^2 + (D^2)*(sigRSsens + RSsens.^2)*(D^2));

RSsensK1 = RSsens + K*(RSobs - RSsens) + Omn*randn(1);
sigRSsensK1 = Q^2 + Omn^2 + (1-K)*sigRSsens;

end
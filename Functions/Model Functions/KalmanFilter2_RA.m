function [ RAsensK1, sigRAsensK1, K, RAobs ] = KalmanFilter2_RA( RAdelay, RAsens, sigRAsens, params )
%RA_KALMAN_FILTER Kalman Filter for Retinal Acceleration
% J Coutinho (2017)


%   Given delayed, deterministic Retinal Acceleration Signal
%   Make estimate of RA
%   sigRAsens is a variance, not standard dev

% dt = 0.001;

if isstruct(params)
    D = params.RA.D;
    R = params.RA.R;
    Q = params.RA.Q;
    Omn = params.RA.Omn;
elseif isnumeric(params)
    if length(params) == 4
        D = params(1);
        R = params(2);
        Q = params(3);
        Omn = params(4);
    else
        fprintf('Size of numeric param vector does not match number of parameters needed to be specified \n See comments for help \n')
    end
end

if nargin < 4
    R = 20;
    D = 1;
    
    Q = 20;
    
    Omn = 10;
end

RAobs = (1+D*randn)*RAdelay + R*randn;

K = sigRAsens / (sigRAsens + R^2 + (D^2)*(sigRAsens + RAsens^2)*(D^2));

RAsensK1 = RAsens + K*(RAobs - RAsens) + Omn*randn;
sigRAsensK1 = Q^2 + Omn^2 + (1-K)*sigRAsens;


end


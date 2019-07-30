function [ PEsensK1, sigPEsensK1, K, PEobs ] = KalmanFilter2_PE( PEdelay, PEsens, sigPEsens, params )
%PE_Kalman_Filter Estimates Sensory PE
% J Coutinho (2017)

%in: PEdet
%Out: K filtered estimate of PE.
%   This function will take a deterministic value of PE
%   PEdet from 'real world' TarMotion and EyeMotion signals
%   This function will introduce noise, then make an estimate over time.
%   Sig is a Variance, not standard deviation.


% Noise Parameters
if isstruct(params)
    D = params.PE.D;
    R = params.PE.R;
    Q = params.PE.Q;
    Omn = params.PE.Omn;
elseif isnumeric(params)
    if length(params) ==4
        D = params(1);
        R = params(2);
        Q = params(3);
        Omn = params(4);
    else
        fprintf('Length of numeric param vector does not match number of params needed to be specified \n See comments for help \n')
    end
end
if nargin< 4
    D = 1;      % Multiplicative noise
    % 100% signal dep noise = Poisson noise, desirable.
    R = 0.5;    % additive noise
    
    Q = 0.2;    % Expectation
    
    Omn = 0.1;  % internal noise
end

PEobs = (1 + D*randn)*PEdelay + R*randn;

K = sigPEsens / (sigPEsens + R^2 + (D^2).*(sigPEsens + PEsens.^2).*(D^2));

PEsensK1 = PEsens + K*(PEobs - PEsens) + Omn*randn;
sigPEsensK1 = Q^2 + Omn^2 + (1-K)*sigPEsens;

end
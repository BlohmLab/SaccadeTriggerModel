function [Sacc, GainMod] = Catch_up_saccade(PE, SaccGain, k, N)
%
% NSCI 850 - Computational Approaches to Neuroscience
%
% Sacc has size [3 x exptDur]: [displacement; velocity; accel]
%
% simple saccade generator model adapted from Scudder 1988 and 
% Jurgens et al. 1981
% & Blohm et al., 2006. 
%
% yout: eye velocity
%
% written by G. Blohm (2015)
% modified by J. Coutinho (2016)

%--------------------------------------------------------------------------

%use this function inside if statement in script
%(if pSaccR > SaccThresh || pSaccL > SaccThresh, Sacc=Catch_up_saccade()


%--------------------------------------------------------------------------

%% initialize 

% N is expt duration in ms
SaccDelay = 40;
dt = 0.001;
t = 0:dt:(N-1).*dt; % time array
deltaE = zeros(size(t));
deltaE((k+SaccDelay):end) = SaccGain*PE; % position error (for model)
% deltaE0 = zeros(size(t));
% deltaE0(k:end) = PE; % position error (for plots) - used to implement saccade latency

T1 = 0.175; % visco-elastic time constant
T2 = 0.013; % inertial time constant
bm = 700; % pulse generator gain
GainMod = 1;

% bm = 600;   %deg/s
e0 = 1;     %deg
bk = 3;     %deg

%% NUMERICAL INTEGRATION CODE
y(1:2) = 0; x2(1:2) = 0; Eint(1:2) = 0; x1(1:2) = 0; dEstar(1:2) = 0; Edot(1:2) = 0; Eint(1:2) = 0;
dEstar = zeros(size(t)); 
gRI = 1; % resettable integrator gain
e = zeros(size(t));
for i = 1:length(t)-1,
    e(i) = deltaE(i) - dEstar(i); % internally estimated saccade error
%     GainMod = 1 - exp( (-e(i) - e0)/bk);
    if e(i) > e0
            GainMod(i) = bm*(1 - exp( (-e(i) - e0)/bk));
    elseif e(i) < -e0
            GainMod(i) = -bm*((1 - exp( (e(i) - e0)/bk)));
            
    elseif abs(e(i)) <= e0
            GainMod(i) = bm*(exp((e(i) - e0)/bk) - exp((-e(i) - e0)/bk));
    end
    
    Edot(i) = GainMod(i); % pulse generator (default gain = 600)
    dEstar(i+1) = dEstar(i) + dt*gRI*Edot(i); % resettable integrator
    
    Eint(i+1) = Eint(i) + dt*Edot(i); % neural integrator
    x1(i+1) = (T1*Edot(i) + Eint(i)); % pulse-step addition
    x2(i+1) = x2(i) + dt/T2*(-x2(i) + x1(i)); % second ocular time constant (inertia)
    y(i+1) = y(i) + dt/T1*(-y(i) + x2(i)); % output after second ocular time constant (visco-elasticity)
end

Sacc = zeros(3,N);

Sacc(1,:) = y;
SaccVel = diff(y');
Sacc(2,:) = (1/dt).*[SaccVel; SaccVel(end)];
Sacc(3,:) = (1/dt).*[diff(Sacc(2,:)), 0];











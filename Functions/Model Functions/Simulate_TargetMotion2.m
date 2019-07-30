function [ TargetMotion, TrialParams  ] = Simulate_TargetMotion2( trialType, conditionVector )
%Simulate_TargetMotion Creates TargetMotion based on trialType and trialDetails in TrialParams
%
% TrialParams [struct] 
% fields: dt, exptDur, onset1, (onset2 if needed), analysisWindow, trialType, trialDetails

% trialType = TrialParams.trialType;
% trialDetails = TrialParams.trialDetails;

dt = 0.001;


%% Single Step Ramp
if strcmpi(trialType, 'singleStepRamp')
    % trialDetails = {PSrange, VSrange, char tag}
    % indexVector = [PSi; VSi]
    % conditionVector = [PS,VS]
    onset1 = 200;
    tvect = -0.2:dt:0.5;
    exptDur = length(tvect);
    
    
    
    TrialParams = struct('exptDur', exptDur, 'onset1', onset1, 'trialType', trialType, 'dt', dt, 'tvect', tvect, 'conditionVector', conditionVector);
    TrialParams.analysisWindow = 500;
    
    PS = conditionVector(1);
    VS = conditionVector(2);

    TargetMotion = zeros(3, exptDur);   %[TarPos; TarVel; TarAccel], dim2 length exptDur
    
    TargetMotion(2,onset1:end) = VS;         % first ramp (vel)
    TargetMotion(1,onset1) = PS;             % first pos step
    TarVelSmooth = zeros(1,exptDur);
    tau = 50; %[ms]
    
    for k = (onset1):(exptDur-1)
        TargetMotion(1,k+1) = TargetMotion(1,k) + dt.*TargetMotion(2,k);
        TarVelSmooth(k+1) = TarVelSmooth(k) + (1/tau).*(TargetMotion(2,k)-TarVelSmooth(k));
    end    
    TargetMotion(3,:) = [(1/dt)*diff(TarVelSmooth), 0];
    
%% Double Step Ramp
elseif strcmpi(trialType, 'doubleStepRamp')
    % trialDeatils = {StepRamp1Range, PSrange, VSrange, char tag}
    % indexVector = [SR1i; PSi; VSi]
    % conditionVector = [SR1_displacement; PS, VS]
    onset1 = 200; 
    tvect1 = -0.2:dt:0.9;
    onset2 = 600;
    tvect2 = -0.6:dt:0.5;
    exptDur = length(tvect2);
    TrialParams = struct('exptDur', exptDur, 'onset1', onset1, 'onset2', onset2, 'trialType', trialType, 'dt', dt, 'tvect1', tvect1, 'tvect2', tvect2, 'conditionVector', conditionVector);
    TrialParams.analysisWindow = 400;
    
    SR1 = [conditionVector(1); -5*conditionVector(1)];
    PS = conditionVector(2);
    VS = conditionVector(3);

    
    TargetMotion = zeros(3,exptDur);
    TargetMotion(2,onset1:(onset2-1)) = SR1(2);  % 1st ramp (vel)
    TargetMotion(2, onset2:end) = SR1(2) + VS;                        % 2nd ramp (vel)
    
    tau=50;                                         %time constant for vel smoothing in accel estimation
    TarVelSmooth = zeros(1,exptDur);    % smoothed Vel trace: for (smoothed) acceleration signal
    
    for k = onset1:(exptDur-1)
       if k == onset1
           TargetMotion(1,k) = TargetMotion(1,k) + SR1(1);      % 1st pos step
       end
       if k == onset2
           TargetMotion(1,k) = TargetMotion(1,k) + PS;          % 2nd pos step
       end
       
       TargetMotion(1,k+1) = TargetMotion(1,k) + dt.*TargetMotion(2,k);
       TarVelSmooth(k+1) = TarVelSmooth(k) + (1/tau).*(TargetMotion(2,k)-TarVelSmooth(k));
    end
    TargetMotion(3,:) = [(1/dt).*diff(TarVelSmooth), 0];
    
    
%% Single Step (static)
elseif strcmpi(trialType, 'singleStep')
    % trialDetails = [PSrange]
    % indexVector = [PSi]
    

%% Double Step (static)
elseif strcmpi(trialType, 'doubleStep')
    % trialDetails = {PSrange1; PSrange2; onset2range}
    % indexVector = [PS1i, PS2i, onseti]

    
%% Sinusoidal Motion
elseif strcmpi(trialType, 'sine')
    
    

%% Ramp motion with Sinusoidal Velocity Perturbation
elseif strcmpi(trialType, 'rampSinePerturbation')


    
%% Invalid trialType
else
    fprintf('trialType is unrecognized, \n Expecting ''singleStepRamp'', ''doubleStepRamp'' \n')
end
end


function [ TargetMotion ] = Simulate_TargetMotion( TrialParams, indexVector )
%Simulate_TargetMotion Creates TargetMotion based on trialType and trialDetails in TrialParams
%
% TrialParams [struct] 
% fields: dt, exptDur, onset1, (onset2 if needed), analysisWindow, trialType, trialDetails

%indexVector = [SRi; PSi; VSi] or [PSi; VSi]

trialType = TrialParams.trialType;
trialDetails = TrialParams.trialDetails;

dt = TrialParams.dt;


%% Single Step Ramp
if strcmpi(trialType, 'singleStepRamp')
    % trialDetails = {PSrange, VSrange, char tag}
    % indexVector = [PSi; VSi]
    VS = trialDetails{2}(indexVector(2));
    if strcmpi(trialDetails{3}, 'txt')
        txt = trialDetails{1}(indexVector(1));  %for 'txt', trialDetails{1} = txtRange
        PS = -txt.*VS;
    else
        PS = trialDetails{1}(indexVector(1));
    end
    
    TargetMotion = zeros(3, TrialParams.exptDur);   %[TarPos; TarVel; TarAccel], dim2 length exptDur
    
    TargetMotion(2,TrialParams.onset1:end) = VS;         % first ramp (vel)
    TargetMotion(1,TrialParams.onset1) = PS;             % first pos step
    TarVelSmooth = zeros(1,TrialParams.exptDur);
    tau = 50; %[ms]
    
    for k = (TrialParams.onset1):(TrialParams.exptDur-1)
        TargetMotion(1,k+1) = TargetMotion(1,k) + dt.*TargetMotion(2,k);
        TarVelSmooth(k+1) = TarVelSmooth(k) + (1/tau).*(TargetMotion(2,k)-TarVelSmooth(k));
    end    
    TargetMotion(3,:) = [(1/dt)*diff(TarVelSmooth), 0];
    
%% Double Step Ramp
elseif strcmpi(trialType, 'doubleStepRamp')
    % trialDeatils = {StepRamp1Range, PSrange, VSrange, char tag}
    % indexVector = [SR1i; PSi; VSi]
    SR1 = trialDetails{1}(:,indexVector(1));
    VS = trialDetails{3}(indexVector(3));
    if strcmpi(trialDetails{4}, 'deBrouwer')
        if VS < -10
            PS = trialDetails{2}(1,indexVector(2));
        elseif VS >10
            PS = trialDetails{2}(3,indexVector(2));
        else
            PS = trialDetails{2}(2,indexVector(2));
        end
        
    elseif strcmpi(trialDetails{4}, 'txt')
        Txt = trialDetails{2}(indexVector(2));
        PS = -Txt.*VS;
    else
        PS = trialDetails{2}(indexVector(2));
    end
    
    
    TargetMotion = zeros(3,TrialParams.exptDur);
    TargetMotion(2,TrialParams.onset1:(TrialParams.onset2-1)) = SR1(2);  % 1st ramp (vel)
    TargetMotion(2, TrialParams.onset2:end) = SR1(2) + VS;                        % 2nd ramp (vel)
    
    tau=50;                                         %time constant for vel smoothing in accel estimation
    TarVelSmooth = zeros(1,TrialParams.exptDur);    % smoothed Vel trace: for (smoothed) acceleration signal
    
    for k = TrialParams.onset1:(TrialParams.exptDur-1)
       if k == TrialParams.onset1
           TargetMotion(1,k) = TargetMotion(1,k) + SR1(1);      % 1st pos step
       end
       if k == TrialParams.onset2
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
    fprintf('trialType is unrecognized, \n Please see top of comments for full list of possible trialType \n')
end
end


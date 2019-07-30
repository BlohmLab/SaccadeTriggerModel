function [ TrialParams ] = Initialize_TrialParams( trialType, trialDetails )
%Initialize_TrialParams Specifies values contained in TrialParams struct
%   Ultimately, TrialParams needs to specify:
% a) How to determine TargetMotion, for range of TargetMotion
%    conditions needed to be simulated
%       --> PSrange, VSrange, sinePertubationRange....
% b) How to determine analysis window for saccades
%       analysis window: scalar, analyze from (onset1):(onset1+analysisWindow)

%%  trialType possibilities:
% singleStepRamp, doubleStepRamp, staticStep, sinePerturbation

% TrialParams has fields:
% exptDur, onset, dt, analysisWindow
% trialType

% trialDetails:    char vector specifying some pre-set
%                       cell array, specifying numeric details, see specs for each trialType

TrialParams = struct;
TrialParams.dt = 0.001;         % [s], for numerical integration, defines time step between k, k+1 is discrete simulation
TrialParams.analysisWindow = 400;       %defines number of time steps after 'event onset' that we consider saccades in
TrialParams.trialType = trialType;
TrialParams.delay = 70;     %[ms]

%% Single Step Ramp
if strcmpi(trialType, 'singleStepRamp')
    TrialParams.onset1 = 200;
    TrialParams.tvect = -0.2:0.001:0.5;
    TrialParams.exptDur = length(TrialParams.tvect);
    
    %TrialParams.trialDetails will be cell with 3 elements
    % {PSrange, VSrange, char tag}
    
    % char tag describes preset: 'bieg', 'txt'
    %                            or 'custom'
    % for char tag = 'txt', specify Txt Range instead of PS range
    % (need if statement in SimulateVisTracking.m function)
    if ischar(trialDetails)
        
        % eg: TrialParams.trialDetails = {PSrange; VSrange; char tag}
        % (note cell array)
        if strcmpi(trialDetails, 'bieg')
            TrialParams.trialDetails{3} = 'bieg';                % char tag
            TrialParams.trialDetails{1} = 1:1:12;                % PSrange
            TrialParams.trialDetails{2} = [-20, -10, 10, 20];    % VSrange
            
        elseif strcmpi(trialDetails, 'txt')            %specifies Txt range instead of PSrange
            TrialParams.trialDetails{3} = 'txt';               % char tag
            TrialParams.trialDetails{1} = -0.8:0.05:0.8;       %Txt Range
            TrialParams.trialDetails{2} = [-30, -20,  -5, 5, 20, 30];  %VSrange
            
        else
            fprintf('unknown (char) pre-set. \n Expecting ''bieg'' or ''txt'' ')
        end
        
    elseif iscell(trialDetails)
        %trialDetails = {PSrange; VSrange; 'custom'} (note, cell array)
        if length(trialDetails)==2
            TrialParams.trialDetails = trialDetails;  %{PSrange;VSrange} specified directly by input
            TrialParams.trialDetails{3} = 'custom';        %char tag = 'custom' since not pre-set input
        end
        TrialParams.trialDetails = trialDetails;
    else
        fprintf('invalid trialDetails (not char or cell) \n See documentation for help \n')
    end
    
    %% Double Step Ramp
elseif strcmpi(trialType, 'doubleStepRamp')
    TrialParams.onset1 = 200;           % absolute value of time of onset1
    TrialParams.onset2 = 200 + 500;     % absolute value of time of onset2
    TrialParams.tvect1 = -0.2:0.001:1;
    TrialParams.tvect2 = -0.7:0.001:0.5;
    TrialParams.exptDur = length(TrialParams.tvect2);
    
    % Note, 500 ms of 2nd step ramp simulated,
    % but only analyzing first 400 ms as specified by TrialParams.analysisWindow
    
    % TrialParams.trialDetails = cell array with 4 elements
    % {StepRamp1; PSrange; VSrange; char tag}
    % StepRamp1 = [-2, -4, -6; 10, 20, 30];
    if ischar(trialDetails)
        
        if strcmpi(trialDetails, 'deBrouwer')
            TrialParams.trialDetails{4} = 'deBrouwer';
            TrialParams.trialDetails{1} = [-2, -4, -6; 10, 20, 30];
            PSrangeNegVS = -10:2:20;
            PSrangeMidVS = -10:2:10;
            PSrangePosVS = -20:2:10;
            sizediff = length(PSrangeNegVS) - length(PSrangeMidVS);
            TrialParams.trialDetails{2} = [PSrangeNegVS; PSrangeMidVS, NaN(1,sizediff); PSrangePosVS];
            TrialParams.trialDetails{3} = [-50:10:50];
            
        elseif strcmpi(trialDetails, 'txt')
            TrialParams.trialDetails{1} = [-2, -4, -6; 10, 20, 30];    %Initial SR [PS;VS]
            TrialParams.trialDetails{2} = -0.3:0.02:0.7;       %txtRange
            TrialParams.trialDetails{3} = [-40, -20, -10, 10, 20, 40];  %VSrange
            TrialParams.trialDetails{4} = 'txt';               % charTag

            
        else
            fprintf('invalid (char) trialDetails \n Valid char inputs: ''deBrouwer'' \n')
        end
        
    elseif iscell(trialDetails)
        % TrialParams.trialDetails = cell array with 4 elements
        % {StepRamp1; PSrange; VSrange; char tag}
        
        if numel(trialDetails)==3
            TrialParams.trialDetails = trialDetails;  %{PSrange;VSrange} specified directly by input
            TrialParams.trialDetails{4} = 'custom';        %char tag = 'custom' since not pre-set input

        else
            fprintf('invalid (cell) trialDetails \n expecting cell array with 3 elements \n {StepRamp1; PSrange; VSrange;} \n')
        end

    else
        fprintf('invalid trialDetails \n (not cell or char) \n See documentation for help \n')
        
    end
    
%% Single (static) Step
elseif strcmpi(trialType, 'singleStep') || strcmpi(trialType, 'staticStep')

    TrialParams.exptDur = 700;
    TrialParams.onset1 = 200;
    
    if isnumeric(trialDetails)         % trialDetails = PSrange;
        TrialParams.trialDetails = trialDetails;
        
    else
        fprintf('for staticStep, expecting trialDetails to be numeric array (PSrange) \n')
        
    end
    
    
%% Double (static) Step
elseif strcmpi(trialType, 'doubleStep')    
    
    TrialParams.exptDur = 1000;
    TrialParams.onset1 = 200;
    
    if iscell(trialDetails)
        TrialParams.trialDetails = trialDetails;      %{PS1range; PS2range; onset2range}
        TrialParams.onset2 = trialDetails{3};
        
    else
        fprintf('Error, expecting cell array size 3x1 with {PSrange1; PSrange2, [onset2 range]}')
    end


%% Sinusoidal Motion
elseif strcmpi(trialType, 'sine')
    
    
    
    
    
%% Ramp Motion with Sinusoidal Perturbation
elseif strcmpi(trialType, 'rampSinePerturbation')
    
    
    
%% Invalid trialType
else
    fprintf('trialType is unrecognized, \n Please see top of comments for full list of possible trialType \n')
end




end


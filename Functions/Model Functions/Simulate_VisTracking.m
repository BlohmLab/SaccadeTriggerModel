function [ rawData, summaryData ] = Simulate_VisTracking( TargetMotion, Params, trialRepeats )
%Simulate_VisTracking Simulates pursuit and saccades for given target motion

%   TarMotion(:,1) specifies TarPos(t)
%   TarMotion(:,2)    "      TarVel(t)
%   Tarmotion(:,3)    "      TarAccel(t)
%   TrialRepeat is how many repetitions we want to simulate

%   Params: struct containing
%TrialParams-
%KalmanParams-
%DecisionParams-
%MotorParams- pursGainMean, pursGainStd, saccGain

% rawData: struct containing all signals of interest, size = (exptDur,
% TrialRepeats)
% summaryData: struct containing saccMetrics, sensMetrics, detMetrics

%% Dealing With Inputs
% TarPos = TargetMotion(:,1);
% TarVel = TargetMotion(:,2);
% TarAccel = TargetMotion(:,2);     %Unneccessary since eqns sorta vectorized

TrialParams = Params.TrialParams;

if nargin <3
    if isfield(TrialParams, 'trialRepeats')
        trialRepeats = TrialParams.trialRepeats;
    else
        fprintf('Error. Need to specify trialRepeats \n Either as a field in TrialParams, or as 3rd input argument \n')
    end
end
%%  trialType possibilities:
% singleStepRamp, doubleStepRamp, staticStep, sinePerturbation

% TrialParams has fields:
% exptDur, onset, dt, analysisWindow
% trialType
% trialDetails:    char vector specifying some pre-set
%                       cell array, specifying numeric details, see specs for each trialType

KalmanParams = Params.KalmanParams;
DecisionParams = Params.DecisionParams;
MotorParams = Params.MotorParams;
dt = 0.001;     % [s]
delay = 70;     %[ms]

%% Initializing Signals
% [pos;vel;accel]
[Eye, deltaDet, deltaSens, sigSens, Ksens, Sacc] = deal(zeros(3,TrialParams.exptDur, trialRepeats));
    sigSens(1,1:delay+1,:) = 100;
    sigSens(2,1:delay+1,:) = 1000;
    sigSens(3,1:delay+1,:) = 1000;

% for pred- [PE;RS], for sacc- [right;left]
[deltaPred, sigPred, pSacc, LLRsacc] = deal(zeros(2,TrialParams.exptDur, trialRepeats));
    sigPred(1,1:delay+1,:) = 100;
    sigPred(2,1:delay+1,:) = 1000;
    
% [time x trialRepeats]
[txeDet] = deal(nan(TrialParams.exptDur, trialRepeats));

% [trialRepeats]
[pursGain] = nan(trialRepeats,1);


if strcmpi(TrialParams.trialType, 'doubleStepRamp') %Conditions where 2 saccade analysis windows need to be tracked. 
   [saccMetrics1, saccMetrics2, sensMetrics1, sensMetrics2, detMetrics1, detMetrics2] = deal(NaN(3,trialRepeats));
else                                                    % Conditions with 1 saccade analysis window (note always looking at first saccades only. 
    [saccMetrics, sensMetrics, detMetrics] = deal(NaN(3,trialRepeats));
    %saccMetrics = [latency(trial); duration(trial); peakVel(trial)]; length=trialRepeats;
    %sensMetrics = [PEsens(k,trial); RSsens(k,trial); PEpred(k,trial)]; length = trialRepeats;
    %detMetrics = [PEdet(k-delay,trial); RSdet(k-delay,trial); TxeDet(k-delay,trial)]; length = trialRepeats
end

Evect = zeros(4, TrialParams.exptDur, trialRepeats);

%% Simulation Loop

for trial = 1:trialRepeats

% Evect = [0;0;0;0];
saccRefract = 0;
pursGain(trial) = MotorParams.pursGainMean + MotorParams.pursGainStd*randn(1);

    for k = (delay+2): TrialParams.exptDur

        %Plant Update
%         Eye(:,k,trial) =[ Eye(1,k-1,trial)+ Evect(1,k-1,trial) + Sacc(1,k,trial); Evect(1,k-1,trial); Evect(2,k-1,trial)];
        Eye(3,k,trial) = Evect(2,k-1,trial);
        Eye(2,k,trial) = Evect(1,k-1,trial);
        Eye(1,k,trial) = Eye(1,k-1,trial) + dt.*Eye(2,k-1,trial) + dt*Sacc(2,k-1,trial);

        deltaDet(:,k,trial) = TargetMotion(:,k) - Eye(:,k,trial);

        if abs(deltaDet(2,k,trial)) > 5
            txeDet(k,trial) = -deltaDet(1,k,trial)./deltaDet(2,k,trial) ;
        end
        
        %Sensory Estimates
        % 1- PE, 2-RS, 3-RA
        [deltaSens(1,k,trial), sigSens(1,k,trial), Ksens(1,k,trial)] =  KalmanFilter2_PE(deltaDet(1,k-delay,trial), deltaSens(1,k-1,trial), sigSens(1,k-1,trial), KalmanParams);
        [deltaSens(2,k,trial), sigSens(2,k,trial), Ksens(2,k,trial)] =  KalmanFilter2_RS(deltaDet(2,k-delay,trial), deltaSens(2,k-1,trial), sigSens(2,k-1,trial), KalmanParams);
        [deltaSens(3,k,trial), sigSens(3,k,trial), Ksens(3,k,trial)] =  KalmanFilter2_RA(deltaDet(3,k-delay,trial), deltaSens(3,k-1,trial), sigSens(3,k-1,trial), KalmanParams);

        %Variance reset at step
%         if strcmpi(TrialParams.trialType, 'doubleStepRamp')
%             if k == TrialParams.onset1 +delay || k == TrialParams.onset2+delay
%                 sigSens(:,k,trial) = [2;20;50].* abs(deltaDet(:,k,trial));
%             end
%         else
%             if k == TrialParams.onset1+delay
%                 sigSens(:,k,trial) = [2;20;50].* abs(deltaDet(:,k,trial));
%             end
%         end
        
        %Sensory Extrapolation
        % 1-PSpred, 2-RSpred
        [deltaPred(1,k,trial), sigPred(1,k,trial)] = PEpredict(deltaSens(1,k,trial), sigSens(1,k,trial), deltaSens(2,k,trial), sigSens(2,k,trial), DecisionParams.RSdelT);
        [deltaPred(2,k,trial), sigPred(2,k,trial)] = RSpredict(deltaSens(2,k,trial), sigSens(2,k,trial), deltaSens(3,k,trial), sigSens(3,k,trial), DecisionParams.RAdelT);
        
        %Pursuit Generator
        Evect(:,k,trial) = PursuitMotionPathway(Evect(:,k-1,trial), deltaPred(2,k,trial), pursGain(trial));
        
        %Sacc Decision
        % 1-Right, 2-Left (neg degrees)
        [pSacc(1,k,trial), pSacc(2,k,trial), LLRsacc(1,k,trial), LLRsacc(2,k,trial)] = SaccDecisionLLR(deltaPred(1,k,trial), sigPred(1,k,trial), pSacc(1,k-1,trial), pSacc(2,k-1,trial), DecisionParams);
        
        %%Sacc Trigger
        saccRefract = saccRefract + 1;
        if saccRefract>250
           if (LLRsacc(1,k,trial) > DecisionParams.saccThresh) || (LLRsacc(2,k,trial) > DecisionParams.saccThresh)
               %Sacc Generation
               currentSacc = Catch_up_saccade(deltaPred(1,k,trial), MotorParams.saccGain, k,TrialParams.exptDur);
               Sacc(:,:,trial) = Sacc(:,:,trial) + currentSacc;     %40ms motor delay between sacc trigger and sacc onset
               saccRefract = 0;
               
               %Record Saccade Data 
               %saccMetrics = [latency; duration; peakVel];
               %sensMetrics = [PEsens; RSsens; PEpred]; at time of sacc trigger (PEpred = SaccAmplitude)
               %detMetrics = [PEdet; RSdet; TxeDet];
               
               % Conditions with 2 analysis windows
               if strcmpi(TrialParams.trialType, 'doubleStepRamp')
                   
               %1st Analysis Window (1st StepRamp)
                   if k > (TrialParams.onset1 + delay)
                       if k < (TrialParams.onset2 +delay)
                           if isnan(saccMetrics1(1,trial))
                               
                              saccMetrics1(:,trial) = Find_SaccadeMetrics2(currentSacc, TrialParams.onset1); %[latency; duration; peakVel]
                              sensMetrics1(:,trial) = [deltaSens(1,k,trial); deltaSens(2,k,trial); deltaPred(1,k,trial)];    %[PEsens; RSsens; PEpred]                           
                              detMetrics1(1:2,trial) = [deltaDet(1,k-delay,trial); deltaDet(2,k-delay,trial)];  %[PEdet; RSdet; TxeDet]
                              if abs(deltaDet(2,k,trial)) > 5
                                   detMetrics1(3,trial) = -deltaDet(1,k-delay,trial)./deltaDet(2,k-delay,trial);
                              end
                           end
                       end
                   end
                   
               %2nd Analysis Window (2nd StepRamp)
                   if k > (TrialParams.onset2 + delay)
                       if k < (TrialParams.onset2 + TrialParams.analysisWindow)
                           if isnan(saccMetrics2(1,trial))
                               
                              saccMetrics2(:,trial) = Find_SaccadeMetrics2(currentSacc, TrialParams.onset2);  %[latency; duration; peakVel];
                              sensMetrics2(:,trial) = [deltaSens(1,k,trial); deltaSens(2,k,trial); deltaPred(1,k,trial)];    %[PEsens; RSsens; PEpred];                           
                              detMetrics2(1:2,trial) = [deltaDet(1,k-delay,trial); deltaDet(2,k-delay,trial)];  %[PEdet; RSdet; TxeDet]
                              if abs(deltaDet(2,k,trial)) > 5
                                   detMetrics2(3,trial) = -deltaDet(1,k-delay,trial)./deltaDet(2,k-delay,trial);
                              end
                           end
                       end
                   end
                   
               % Conditions with single analysis window
               else         
                   
                   if k > (TrialParams.onset1 + delay)
                       if k < (TrialParams.onset1 + TrialParams.analysisWindow)
                           if isnan(saccMetrics(1,trial))    %If first saccade in trial

                               saccMetrics(:,trial) = Find_SaccadeMetrics2(currentSacc, TrialParams.onset1);  %[latency; duration; peakVel];
                               sensMetrics(:,trial) = [deltaSens(1,k,trial); deltaSens(2,k,trial); deltaPred(1,k,trial)];   %[PEsens; RSsens; PEpred];
                               detMetrics(1:2,trial) = [deltaDet(1,k-delay,trial); deltaDet(2,k,trial)];    %[PEdet; RSdet; TxeDet]
                               if abs(deltaDet(2,k,trial)) > 5
                                   detMetrics(3,trial) = -deltaDet(1,k-delay,trial)./deltaDet(2,k-delay,trial);
                               end
                                   
                           end
                       end
                   end
               end

           end      
        end     % end of saccade execution


    end     %end of trial
    
    %if no saccade, calculate smooth Txe
    %if single stepramp
    if strcmpi(TrialParams.trialType, 'singleStepRamp')
        if isnan(saccMetrics(1,trial))  %if smooth trial, calculate Txe as mean(Txe) for interval
            detMetrics(3,trial) = mean(txeDet(TrialParams.onset1:(TrialParams.onset1+400)), 'omitnan');
            
        end
    %if double stepramp
    elseif strcmpi(TrialParams.trialType, 'doubleStepRamp')
        if isnan(saccMetrics1(1,trial)) %if smooth trial, calculate Txe as mean(Txe) for interval
            detMetrics1(3,trial) = mean(txeDet(TrialParams.onset1:(TrialParams.onset1+400)), 'omitnan');
        end
        if isnan(saccMetrics2(1,trial))
            detMetrics2(3,trial) = mean(txeDet(TrialParams.onset1:(TrialParams.onset1+400)), 'omitnan');
        end
        
    end
    
   
    
end         %end of all trialRepeats

if strcmpi(TrialParams.trialType, 'doubleStepRamp')
    conditionSaccMetrics1(1,1) = sum(~isnan(saccMetrics1(1,:)))/trialRepeats;     %Sacc Proportion
    conditionSaccMetrics1(2,1) = mean(saccMetrics1(1,:), 'omitnan');              %mean SRT
    conditionSaccMetrics1(3,1) = std(saccMetrics1(1,:),'omitnan');                %std(SRT)
    
    conditionSaccMetrics2(1,1) = sum(~isnan(saccMetrics2(1,:)))/trialRepeats;     %Sacc Proportion
    conditionSaccMetrics2(2,1) = mean(saccMetrics2(1,:), 'omitnan');              %mean SRT
    conditionSaccMetrics2(3,1) = std(saccMetrics2(1,:),'omitnan');                %std(SRT)
else
    conditionSaccMetrics(1,1) = sum(~isnan(saccMetrics(1,:)))/trialRepeats;     %Sacc Proportion
    conditionSaccMetrics(2,1) = mean(saccMetrics(1,:), 'omitnan');              %mean SRT
    conditionSaccMetrics(3,1) = std(saccMetrics(1,:),'omitnan');                %std(SRT)
end

%For conditions with 2 analysis windows
if strcmpi(TrialParams.trialType, 'doubleStepRamp')
        summaryData = struct('saccMetrics1', saccMetrics1, 'saccMetrics2', saccMetrics2,...
        'sensMetrics1', sensMetrics1, 'sensMetrics2', sensMetrics2, ...
        'detMetrics1', detMetrics1, 'detMetrics2', detMetrics2, ...
        'conditionSaccMetrics1', conditionSaccMetrics1, 'conditionSaccMetrics2', conditionSaccMetrics2);
    
%For conditions with 1 analysis window
else
    summaryData = struct('saccMetrics', saccMetrics, 'sensMetrics', sensMetrics, ...
        'detMetrics', detMetrics, 'conditionSaccMetrics', conditionSaccMetrics);
end

%Raw files are same regardless of analysis window numbers
rawData = struct('Eye', Eye, 'deltaDet', deltaDet, 'deltaSens', deltaSens, 'sigSens', sigSens, ...
                    'Ksens', Ksens, 'Sacc', Sacc, 'deltaPred', deltaPred, 'sigPred', sigPred, ...
                    'pSacc', pSacc, 'LLRsacc', LLRsacc, 'txeDet', txeDet, 'pursGain', pursGain, 'TargetMotion', TargetMotion);
                


end


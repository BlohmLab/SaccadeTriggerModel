function [ RawData, SummaryData, Params ] = Simulate_FullExpt( trialType, trialDetails, trialRepeats, Params )
%Simulate_FullExpt Simulates all conditions specified by trialType, trialDetails
%   Detailed explanation goes here

%% Simulate range of target motions,
if nargin <4
Params = Initialize_DefaultTriggerModel;
end
%Specify Target Motion Range -----> Specified in Input
%trialType: 'singleStepRamp', 'doubleStepRamp'

%DoubleStepRamp custom ranges: input: trialDetails = {SR1range; PSrange; VSrange}
% trialDetails{1} = [2, -2; -10,10];      %SR1 range
% trialDetails{2} = -5:2:10;              %PSrange
% trialDetails{3} = [-10,-20,-30];        %VSrange
%
% preset trialDetails: 'deBrouwer'


TrialParams = Initialize_TrialParams(trialType, trialDetails );
TrialParams.trialRepeats = trialRepeats;
Params.TrialParams = TrialParams;

if strcmpi(trialType, 'doubleStepRamp')
    
    SR1length = size(TrialParams.trialDetails{1},2);
    VSlength = size(TrialParams.trialDetails{3},2);
    PSlength = size(TrialParams.trialDetails{2},2);    %This is for filename, PSlength will be updated for looping if/when contingent on VS
    
    %Initialize Data storage
    filename = sprintf('Initialized_Signals_%d_x_%d_x_%d_x_%d_x_%d.mat', TrialParams.exptDur, trialRepeats, PSlength, VSlength, SR1length);
    
    %if exist....
    if exist(filename, 'file') == 2
        load(filename)
    else
        Initialize_SimulationSignals(TrialParams);
        load(filename)
    end
    
    %Simulate
    for SR1i = 1:SR1length
        for VSi = 1:VSlength
            %In case PSrange is contingent on VS
            if strcmpi(TrialParams.trialDetails{4}, 'deBrouwer')
                %TrialParams.trialDetails = {SR1range; PSrange; VSrange; chartag} for trialType = 'doubleStepRamp'
                VS = TrialParams.trialDetails{3}(VSi);
                
                if VS < -10
                    PSlength = length(TrialParams.trialDetails{2}(1,:));
                elseif VS >10
                    PSlength = length(TrialParams.trialDetails{2}(3,:));
                else
                    PSlength = length(TrialParams.trialDetails{2}(2,:));
                end
            else %if 'txt'
                PSlength = length(TrialParams.trialDetails{2});
            end
            
            for PSi = 1:PSlength
                
                indexVector = [SR1i; PSi; VSi];
                TargetMotion = Simulate_TargetMotion(TrialParams, indexVector);
                [rawData, summaryData] = Simulate_VisTracking(TargetMotion, Params, trialRepeats);
                
                %%Store simulation data%%
                % Output from Simulate_VisTracking is for single condition, all trialRepeats
                
                %Double Step Ramps
                
                %Raw
                % size: [3 x exptDur x trialRepeat x PSrange x VSrange x SR1range], dim1: [pos;vel;accel]
                Eye(:,:,:,PSi,VSi,SR1i) = rawData.Eye;
                Sacc(:,:,:,PSi,VSi,SR1i) = rawData.Sacc;
                deltaDet(:,:,:,PSi,VSi,SR1i) = rawData.deltaDet;
                deltaSens(:,:,:,PSi,VSi,SR1i) = rawData.deltaSens;
                sigSens(:,:,:,PSi,VSi,SR1i) = rawData.sigSens;
                Ksens(:,:,:,PSi,VSi,SR1i) = rawData.Ksens;
                
                % size: [2 x exptDur x trialRepeats x PSrange x VSrange x SR1range], dim1: [pos;vel] or [right; left]
                deltaPred(:,:,:,PSi,VSi,SR1i) = rawData.deltaPred;
                sigPred(:,:,:,PSi,VSi,SR1i) = rawData.sigPred;
                pSacc(:,:,:,PSi,VSi,SR1i) = rawData.pSacc;
                LLRsacc(:,:,:,PSi,VSi,SR1i) = rawData.LLRsacc;
                
                % size: [exptDur x trialRepeats x PSrange x VSrange x SR1range]
                txeDet(:,:,PSi,VSi,SR1i) = rawData.txeDet;
                
                % size: [trialRepeats x PSrange x VSrange x SR1range]
                pursGain(:,PSi,VSi,SR1i) = rawData.pursGain;
                
                %Summary
                % size: [3 x trialRepeats x PSrange x VSrange x SR1range]
                saccMetrics1(:,:,PSi,VSi,SR1i) = summaryData.saccMetrics1;  %[
                saccMetrics2(:,:,PSi,VSi,SR1i) = summaryData.saccMetrics2;
                sensMetrics1(:,:,PSi,VSi,SR1i) = summaryData.sensMetrics1;
                sensMetrics2(:,:,PSi,VSi,SR1i) = summaryData.sensMetrics2;
                detMetrics1(:,:,PSi,VSi,SR1i) = summaryData.detMetrics1;
                detMetrics2(:,:,PSi,VSi,SR1i) = summaryData.detMetrics2;
                
                conditionSaccMetrics1(:,PSi,VSi,SR1i) = summaryData.conditionSaccMetrics1;
                conditionSaccMetrics2(:,PSi,VSi,SR1i) = summaryData.conditionSaccMetrics2;
                
            end
        end
    end
    
else    %singleStepRamp
    
    VSlength = size(TrialParams.trialDetails{2},2);
    PSlength = size(TrialParams.trialDetails{1},2);
    
    %Initialize Data storage
    filename = sprintf('Initialized_Signals_%d_x_%d_x_%d_x_%d.mat', TrialParams.exptDur, trialRepeats, PSlength, VSlength);
    
    %if exist....
    if exist(filename, 'file') == 2
        load(filename)
    else
        Initialize_SimulationSignals(TrialParams);
        load(filename)
    end
    
    %Simulate
    for VSi = 1:VSlength
        %In case PSrange is contingent on VS
        % typically not in singleStepRamps, so ignore for now. Can write something in later if/when relevent
        
        for PSi = 1:PSlength
            
            indexVector = [PSi; VSi];
            TargetMotion = Simulate_TargetMotion(TrialParams, indexVector);
            [rawData, summaryData] = Simulate_VisTracking(TargetMotion, Params, trialRepeats);
            
            %%Store simulation data%%
            % Output from Simulate_VisTracking is for single condition, all trialRepeats
            
            %Raw
            % size: [3 x exptDur x trialRepeat x PSrange x VSrange], dim1: [pos;vel;accel]
            Eye(:,:,:,PSi,VSi) = rawData.Eye;
            Sacc(:,:,:,PSi,VSi) = rawData.Sacc;
            deltaDet(:,:,:,PSi,VSi) = rawData.deltaDet;
            deltaSens(:,:,:,PSi,VSi) = rawData.deltaSens;
            sigSens(:,:,:,PSi,VSi) = rawData.sigSens;
            Ksens(:,:,:,PSi,VSi) = rawData.Ksens;
            
            % size: [2 x exptDur x trialRepeats x PSrange x VSrange], dim1: [pos;vel] or [right; left]
            deltaPred(:,:,:,PSi,VSi) = rawData.deltaPred;
            sigPred(:,:,:,PSi,VSi) = rawData.sigPred;
            pSacc(:,:,:,PSi,VSi) = rawData.pSacc;
            LLRsacc(:,:,:,PSi,VSi) = rawData.LLRsacc;
            
            % size: [exptDur x trialRepeats x PSrange x VSrange]
            txeDet(:,:,PSi,VSi) = rawData.txeDet;
            
            % size: [trialRepeats x PSrange x VSrange]
            pursGain(:,PSi,VSi) = rawData.pursGain;
            
            %Summary
            % size: [3 x trialRepeats x PSrange x VSrange]
            saccMetrics(:,:,PSi,VSi) = summaryData.saccMetrics;
            sensMetrics(:,:,PSi,VSi) = summaryData.sensMetrics;
            detMetrics(:,:,PSi,VSi) = summaryData.detMetrics;
            
            conditionSaccMetrics(:,PSi,VSi) = summaryData.conditionSaccMetrics;

        end
    end 
    
end

%Store all data into convenient structs
RawData = struct('Eye', Eye, 'deltaDet', deltaDet, 'deltaSens', deltaSens, 'sigSens', sigSens, ...
    'Ksens', Ksens, 'Sacc', Sacc, 'deltaPred', deltaPred, 'sigPred', sigPred, ...
    'pSacc', pSacc, 'LLRsacc', LLRsacc, 'txeDet', txeDet, 'pursGain', pursGain, ...
    'Params', Params);
if strcmpi(TrialParams.trialType, 'doubleStepRamp')
    SummaryData = struct('saccMetrics1', saccMetrics1, 'sensMetrics1', sensMetrics1, 'detMetrics1', detMetrics1,...
        'saccMetrics2', saccMetrics2, 'sensMetrics2', sensMetrics2, 'detMetrics2', detMetrics2, ...
        'conditionSaccMetrics1', conditionSaccMetrics1, 'conditionSaccMetrics2', conditionSaccMetrics2, ...
        'Params', Params);
    
else
    SummaryData = struct('saccMetrics', saccMetrics, 'sensMetrics', sensMetrics, ...
        'detMetrics', detMetrics, 'conditionSaccMetrics', conditionSaccMetrics, ...
        'Params', Params);
end



end


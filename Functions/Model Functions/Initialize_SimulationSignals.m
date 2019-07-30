function [  ] = Initialize_SimulationSignals( TrialParams )
%Initialize_SimulationSignals Creates zero matrices for simulation signals
% for expt specified by TrialParams.
% Need to clean up comments


if strcmpi(TrialParams.trialType, 'singleStepRamp')
    if strcmpi(TrialParams.trialDetails{3}, 'txt')
        PSlength = length(TrialParams.trialDetails{1});    %Yes this is redundant...
    else
        PSlength = length(TrialParams.trialDetails{1});
    end
        VSlength = length(TrialParams.trialDetails{2});
        trialRepeats = TrialParams.trialRepeats;
        exptDur = TrialParams.exptDur;

    
        filename = sprintf('Initialized_Signals_%d_x_%d_x_%d_x_%d.mat', exptDur, trialRepeats, PSlength, VSlength);
        %Note this filename ignores the first dim of some rawdata values. 
    
    %Kinematics Variables
    [Eye, Sacc] = deal(NaN(3,exptDur, trialRepeats, PSlength, VSlength));
    
    %Sensory Variables
    [deltaDet, deltaSens, sigSens, Ksens] = deal(NaN(3,exptDur, trialRepeats, PSlength, VSlength));
    
    %Prediction Variables
    [deltaPred, sigPred] = deal(NaN(2,exptDur, trialRepeats, PSlength, VSlength));
    
    %Decision Variables
    [pSacc, LLRsacc] = deal(NaN(2,exptDur, trialRepeats, PSlength, VSlength));
    
    %Other
    pursGain = NaN(trialRepeats, PSlength, VSlength);
    txeDet = NaN(exptDur, trialRepeats, PSlength, VSlength);
    
    %Summary Variables
    [saccMetrics, sensMetrics, detMetrics] = deal(NaN(3, trialRepeats, PSlength, VSlength));

    
    %Save
    cd('E:\OneDrive - Queen''s University\Basic Simulations\Saccade Trigger Model Final\Simulation Data')
    save(filename, '-v7.3')
    cd('E:\OneDrive - Queen''s University\Basic Simulations\Saccade Trigger Model Final')
    
elseif strcmpi(TrialParams.trialType, 'doubleStepRamp')
        
    trialRepeats = TrialParams.trialRepeats;
    exptDur = TrialParams.exptDur;
    PSlength = length(TrialParams.trialDetails{2});
    VSlength = length(TrialParams.trialDetails{3});
    StepRamp1length = size(TrialParams.trialDetails{1},2);

    filename = sprintf('Initialized_Signals_%d_x_%d_x_%d_x_%d_x_%d.mat', exptDur, trialRepeats, PSlength, VSlength, StepRamp1length);


    %Kinematics Variables
    [Eye, Sacc] = deal(NaN(3,exptDur, trialRepeats, PSlength, VSlength));
    
    %Sensory Variables
    [deltaDet, deltaSens, sigSens, Ksens] = deal(NaN(3,exptDur, trialRepeats, PSlength, VSlength, StepRamp1length));
    
    %Prediction Variables
    [deltaPred, sigPred] = deal(NaN(2,exptDur, trialRepeats, PSlength, VSlength, StepRamp1length));
    
    %Decision Variables
    [pSacc, LLRsacc] = deal(NaN(2,exptDur, trialRepeats, PSlength, VSlength, StepRamp1length));
    
    %Other
    pursGain = NaN(trialRepeats, PSlength, VSlength, StepRamp1length);
    txeDet = NaN(exptDur, trialRepeats, PSlength, VSlength, StepRamp1length);

    %Summary Variables
    [saccMetrics1, sensMetrics1, detMetrics1] = deal(NaN(3, trialRepeats, PSlength, VSlength, StepRamp1length));
    [saccMetrics2, sensMetrics2, detMetrics2] = deal(NaN(3, trialRepeats, PSlength, VSlength, StepRamp1length));

    %Save
    cd('E:\OneDrive - Queen''s University\Basic Simulations\Saccade Trigger Model Final\Simulation Data')
    save(filename, '-v7.3')
    cd('E:\OneDrive - Queen''s University\Basic Simulations\Saccade Trigger Model Final')
    
end

end


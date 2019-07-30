%% Plot Parameter Variations
% JD Coutinho, P Lefevre, G Blohm 2019 (j.coutinho@queensu.ca)
% Confidence in predicted position error explains saccadic decisions during pursuit
% doi: https://doi.org/10.1101/396788


%% Testing parameter variations in decisionParams on singleStepRamp results
% ie plot(saccprop, srt vs position step, for VS=20

paramValue = 'update';
paramRange = 3.5:0.2:4.5;   %Thresh
% paramRange = [15, 25, 35, 50, 75];  %tau
% paramRange = 0.05:0.05:0.25;   %update

%Set Up Param Values (these two never change)
KalmanParams = Initialize_KalmanParams;
MotorParams = Initialize_MotorParams;

%default decision variable values:
tau = 25;
thresh = 4.0;
update = 0.125;

%input to DecisionParams fn = [RSdelT; RAdelT; peThresh; decisionTau; saccThresh; decisionNoise];
% 3,6= 0;
% we care about 1 - extrapolation time ('update')
%               4 - decision time constant
%           and 5 - saccade threshold


trialType = 'singleStepRamp';
%trialDetails = { [PSrange], [VSrange], 'charTag' }
PSrange = -4:10;
VSrange = -20;
trialDetails = {PSrange, VSrange, 'custom_paramVariation'};
trialRepeats = 100;

cmap = brewermap(length(paramRange)+1, '*greys');


figure
figN = get(gcf, 'number');

for iParam = 1:length(paramRange)
    
    
    thresh = paramRange(iParam);
    DecisionParams = Initialize_DecisionParams([update; 0.07; 0; tau;  thresh; 0]);

    Params = struct('KalmanParams', KalmanParams, 'DecisionParams', DecisionParams, ...
                        'MotorParams', MotorParams);    
    %SimulateFullExpt makes TrialParam struct out of trialType, trialDetails, trialRepeats.
    % logic behind that was sometimes inputs are chars, eg 'bieg', and let fn figure out real trialParam values. 
    [RawData, SummaryData, Params ] = Simulate_FullExpt(trialType, trialDetails, trialRepeats, Params);
    
    Plot_SRT_SaccProp( SummaryData, Params, cmap(iParam,:), figN)

end
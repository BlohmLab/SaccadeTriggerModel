%% Simulating Single Trials

% JD Coutinho, P Lefevre, G Blohm 2019 (j.coutinho@queensu.ca)
% Confidence in predicted position error explains saccadic decisions during pursuit
% doi: https://doi.org/10.1101/396788


%This script makes use of 
% Simulate_TargetMotion2.m to create targetMotion vector and TrialParams struct based on specified targetMotion conditions
% Simulate_VisTracking.m to simulate pursuit and saccadic responses
% Plot_SingleTrials.m to plot data


%% Initial Setup %

Params = Initialize_DefaultTriggerModel;        %Initializes Params with fields: KalmanParams, DecisionParams, MotorParams, see functions for param values

%% Single Step Ramp Simulations

figure                                        %create new (empty) figure
figN = get(gcf, 'number');                      %keep track of figure number (to plot multiple things on same figure)
trialRepeats = 1; 

PS = 2;
VS = 10;

%%Specify TargetMotion Parameters %%
stepRamp_petal = [PS,-VS];                        %foveopetal = target step away from fovea, move with constant vel towards fovea
[targetMotionPetal, TrialParamsPetal] = Simulate_TargetMotion2('singleStepRamp', stepRamp_petal);   %outputs targetMotion vector and TargetParams struct based on ('trialType', [PS;VS])
Params_petal = Params;
Params_petal.TrialParams = TrialParamsPetal;     %load TrialParams into Params struct (simplifies inputs for next functions)

%Simulate Oculomotor Response
[RawData_petal, SummaryData_petal] = Simulate_VisTracking(targetMotionPetal, Params_petal, trialRepeats);  
%Plot Simulation
[legendHandle, legendLabels] = Plot_SingleTrials(RawData_petal, Params_petal, trialRepeats, 'petal');


%%Foveofugal Target Motion %%
stepRamp_fugal = [PS,VS];                         %foveofugal = target step away from fovea, and move with constant vel away from fovea
[targetMotionFugal, TrialParamsFugal] = Simulate_TargetMotion2('singleStepRamp', stepRamp_fugal);    %Simulate_TargetMotion2 creates the vector for target motion [pos;vel;accel] for the motion type specified, and a Param vector with trialDetails for latency measurements etc,
Params_fugal = Params;
Params_fugal.TrialParams = TrialParamsFugal;     

%Simulate Oculomotor Response
[RawData_fugal, SummaryData_fugal] = Simulate_VisTracking(targetMotionFugal, Params_fugal, trialRepeats);  %RawData contains full time series for all relevent signals in simulation, SummaryData constains SaccProp, SRT, sensory conditions prior to saccade trigger
%Plot Simulation
%To plot on same figure: keep figure active, and input previous legendHandle,legendLabels as addition arguments
[legendHandle, legendLabels] = Plot_SingleTrials(RawData_fugal, Params_fugal, trialRepeats, 'fugal', legendHandle, legendLabels);     %


%%Comparing against static target displacement %%
step_static = [PS,0];
[targetMotionStatic, TrialParamsStatic] = Simulate_TargetMotion2('singleStepRamp', step_static);
Params_static = Params;
Params_static.TrialParams = TrialParamsStatic;

[RawData_static, SummaryData_static] = Simulate_VisTracking(targetMotionStatic, Params_static, trialRepeats);
figure(figN)
[legendHandle, legendLabels] = Plot_SingleTrials(RawData_static, Params_static, trialRepeats, 'static', legendHandle, legendLabels);

% 
% %Plot RS vs PE
% % figure(2)
% figN2 = get(gcf,'number');
% [legendHandle2, legendLabels2] = Plot_SingleTrial_Phase(RawData_fugal, Params_fugal, SummaryData_fugal, trialRepeats, 'fugal');
% [legendHandle2, legendLabels2] = Plot_SingleTrial_Phase(RawData_petal, Params_petal, SummaryData_petal, trialRepeats, 'petal', legendHandle2, legendLabels2);
% 
% 
% 
% % figure(3)
% Plot_SingleTrial_Phase2(RawData_fugal, Params_fugal, SummaryData_fugal, trialRepeats)
% Plot_SingleTrial_Phase2(RawData_petal, Params_petal, SummaryData_petal, trialRepeats)


%% Double Step Ramp Simulations
%Same as above, but [PS;VS] occur during pursuit maintenance following initial Rashbass (1961) paradigm

figure
fign = get(gcf, 'number');
trialRepeats = 1;

%Specify target motion: [1st position step (Rashbass Paradigm); 2nd change in position; 2nd change in velocity]
DSR_petal = [-2, 4, -20];                           %DSR = doubleStepRamp
[targetMotionPetalDSR, TrialParamsPetalDSR] = Simulate_TargetMotion2('doubleStepRamp', DSR_petal);  %outputs targetMotion vector and TrialParams struct given ('trialType', [PS1;PS2;VS2]) PS1 for initial Rashbass (VS=-0.2PS) 
Params_petalDSR = Params;
Params_petalDSR.TrialParams = TrialParamsPetalDSR;

[RawData_petalDSR, SummaryData_petalDSR] = Simulate_VisTracking(targetMotionPetalDSR, Params_petalDSR, trialRepeats);
[legendHandleDSR, legendLabelsDSR] = Plot_SingleTrials(RawData_petalDSR, Params_petalDSR, trialRepeats, 'petal');

%Foveofugal 2nd stepramp
DSR_fugal = [-2,4,20];
[targetMotionFugalDSR, TrialParamsFugalDSR] = Simulate_TargetMotion2('doubleStepRamp', DSR_fugal);
Params_fugalDSR = Params;
Params_fugalDSR.TrialParams = TrialParamsFugalDSR;

[RawData_fugalDSR, SummaryData_fugalDSR] = Simulate_VisTracking(targetMotionFugalDSR, Params_fugalDSR, trialRepeats);
[legendHandleDSR, legendLabelsDSR] = Plot_SingleTrials(RawData_fugalDSR, Params_fugalDSR, trialRepeats, 'fugal', legendHandleDSR, legendLabelsDSR);


%% Plot Txe 
Params = Initialize_DefaultTriggerModel;
                      %keep track of figure number (to plot multiple things on same figure)
trialRepeats = 50;   

%%Specify TargetMotion Parameters %%
stepRamp_petal = [4,-20];                        %foveopetal = step away from fovea, move with constant vel towards fovea
[targetMotionPetal, TrialParamsPetal] = Simulate_TargetMotion2('singleStepRamp', stepRamp_petal);
Params_petal = Params;
Params_petal.TrialParams = TrialParamsPetal;     %load TrialParams into Params struct (simplifies inputs for next functions)

%Simulate Oculomotor Response
[RawData_petal, SummaryData_petal] = Simulate_VisTracking(targetMotionPetal, Params_petal, trialRepeats);  

%Plot Txe
%RawData.txeDet [time, trial, PS, VS, SR1]
figure 
figN = get(gcf, 'number');
hold on
cmap_b = brewermap(trialRepeats+10, '*blues');
for i = 1:trialRepeats
    subplot(2,1,1)
    hold on
    plot(TrialParamsPetal.tvect, RawData_petal.txeDet(:,i), 'color', cmap_b(i,:))
    subplot(2,1,2)
    hold on
    meanTxe(i) = mean(RawData_petal.txeDet(TrialParamsPetal.onset1 : (TrialParamsPetal.onset1+400),i), 'omitnan');
    stdTxe(i) = std(RawData_petal.txeDet(TrialParamsPetal.onset1: (TrialParamsPetal.onset1+400),i), 'omitnan');
    errorbar(i, meanTxe(i), stdTxe(i), 'color', cmap_b(i,:), 'marker', 'o')
end
subplot(2,1,1)
ylim([-1,1])
xlim([-0.2, 0.4])
ylabel('Txe (s)')
xlabel('Time (s)')

subplot(2,1,2)
ylabel('mean Txe')
xlabel('Trial Number (arbitrary)')
ylim([-0.2, 0.4])

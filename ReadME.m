%% README

%JD Coutinho, P Lefevre, G Blohm 2019  (j.coutinho@queensu.ca)
% Confidence in predicted position error explains saccadic decisions during pursuit
% doi: https://doi.org/10.1101/396788


%% Introduction

%The files contained within simulate 1D visual tracking (pursuit and saccadic eye movements) to simulated target motion
% To replicate manuscript findings, the main scripts are:
% Simulate_SingleTrials.m --> Fig 4, 6
% Simulate_Experiment.m --> Fig 5, 7, 9, 10
% Simulate_PhasePlot.m --> Fig 8
% Plot_ParamVariations.m --> Fig 11
% (Fig 1-2, model block diagrams; Fig 3. Saccade Decision Schematic Diagram)

% To quickly replicate Figs, 
% Load pre-simulated data 
% Fig 5 --> Plot_bieg.m(SummaryData_bieg, Params_bieg)
% Fig 7 --> Plot_deBrouwer3(SummaryData_txt, Params_txt)
% Fig 9 --> Plot_deBrouwer2(SummaryData_txt, Params_txt)
% Fig 10 --> Plot_SRTdistributions(SummaryData, Params), txt or BLUR

%% Contents
% This directory should have 3 folders: Functions, Scripts, Simulation Data

%Functions
% %Plotting Functions 
    % Plot_bieg.m
    % Plot_deBrouwer2.m
    % Plot_deBrouwer3.m
    % Plot_SingleTrials.m
    % Plot_SRT_SaccProp.m
    % Plot_SRTdistributions.m
    %(external):
    % brewermap.m
    % ciplot.m
    % linspecer.m
    % boundedline package
    %Colormaps package
% %Model Functions
    % Calculate_SaccadeMetrics.m
    % Catch_up_saccade.m
    % Find_conditionVector.m
    % Find_SaccadeMetrics2.m
    % Initialize_DecisionParams.m
    % Initialize_DefaultTriggerModel.m
    % Initialize_KalmanParams.m
    % Initialize_MotorParams.m
    % Initialize_SimulationSignals.m
    % Initialize_TrialParams.m
    % KalmanFilter2_PE.m
    % KalmanFilter2_RS.m
    % KalmanFilter2_RA.m
    % LeakyIntegrator.m
    % PEpredict.m
    % RSpredict.m
    % PursuitMotionPathway.m
    % SaccDecisionLLR.m
    % Simulate_FullExpt.m
    % Simulate_TargetMotion.m
    % Simulate_TargetMotion2.m
    % Simulate_VisTracking.m

%Scripts
    % Plot_ParamVariations.m
    % Simulate_Experiment.m
    % Simulate_PhasePlot.m
    % Simulate_SingleTrials.m

%Simulation Data
    % SaccConfidencePhasePlot.mat
    % SimData_bieg.mat
    % SimData_txt.mat
    % SimData_txt_BLUR.mat

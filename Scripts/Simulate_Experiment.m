%% Simulate_Experiment
%
% JD Coutinho, P Lefevre, G Blohm 2019 (j.coutinho@queensu.ca)
% Confidence in predicted position error explains saccadic decisions during pursuit
% doi: https://doi.org/10.1101/396788

% This script makes use of the functions
% Simulate_FullExpt.m to simulate visual tracking based on params used in behavioural experiments
% Specific plot functions to reproduce behavioural findings (Bieg et al 2015; de Brouwer et al., 2002)
% Plot_bieg.m to plot saccade occurence and trigger time based on target step and target speed during pursiut initiation (single step ramp target motion)
% Plot_deBrouwer2.m plots saccade occurence and trigger time based on time-to-foveation (Txe) 125 ms before saccade or averaged across first 400ms of purusit for trials without saccade
% Plot_deBrouwer3.m plots (PE,RS) 125 ms before saccade occurrence 
% Plot_SRTdistributions., plots histograms of saccade trigger time sorted by target crossing time (Txt = -(position step/velocity step)


%% Simulate Bieg et al 2015. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4534514/pdf/221_2015_Article_4323.pdf

%Specify Trial Params: trialRepeats, trialType (eg: singleStepRamp, doubleStepRamp), trialDetails (see documentation for details, can either explicitly specify sets of target motion conditions, or use a prespecified expt setting)
trialType = 'singleStepRamp';
trialDetails = 'bieg';                  %See documentation for details, VSrange = [-20, -10, 10, 20], PSrange = [2:2:12]
trialRepeats = 100;                     %100 repetitions per (PS,VS) combination

%Simulate Bieg expt
[RawData_bieg, SummaryData_bieg, Params_bieg] = Simulate_FullExpt(trialType, trialDetails, trialRepeats);

%Plot
Plot_bieg(SummaryData_bieg, Params_bieg);


%Save Simulation Data
str_timestamp = date;
filename = sprintf('SimData_biegrep%g_%s', trialRepeats, str_timestamp);
save(filename, 'RawData_bieg', 'SummaryData_bieg', 'Params_bieg', '-v7.3')

%% Simulate de Brouwer et al 2002. http://www.ncbi.nlm.nih.gov/pubmed/11877535
%'deBrouwer' uses same (PS,VS) conditions used in de Brouwer et al., 2002;
% these conditions produce target motion covering range of (PS,VS)
% 'txt' selects (PS,VS) with better resolution between -0.3<Txt<0.6 s
% these conditions are better for evaluating saccade decision making as a function of time-to-foveation and better resolve different Txt/Txe
% For this reason, Coutinho et al., 2019 describe 'txt' results rather than 'deBrouwer' to better address previous saccade decision correlates with Txe. However, 'deBrouwer' produces very similar results but trials with small Txt are overrepresented by trials with larger VS

%Initialize Trial Params
trialType = 'doubleStepRamp';
trialDetails = 'deBrouwer';
trialRepeats = 50;

%Simulate
[RawData_deBrouwer, SummaryData_deBrouwer, Params_deBrouwer] = Simulate_FullExpt(trialType, trialDetails, trialRepeats);

%Save Simulation Data
str_timestamp = date;
filename = sprintf('SimData_deBrouwer_rep%g_%s', trialRepeats, str_timestamp);
save(filename, 'RawData_deBrouwer', 'SummaryData_deBrouwer', 'Params_deBrouwer', '-v7.3')

%Plot

%Plot RSsens vs PEsens 125 ms before saccade onset
%SummaryData.sensMetrics = [PEsens, RSsens, PEpred];
%SummaryData.detMetrics = [PEdet, RSdet, Txe]
%TrialParams.trialDetails: 1x4 cell: {SR1range, PErange, VSrange, 'deBrouwer'}

Plot_deBrouwer2(SummaryData_deBrouwer, Params_deBrouwer);
Plot_deBrouwer3(SummaryData_deBrouwer, Params_deBrouwer);


%% Simulate de Brouwer et al 2002. http://www.ncbi.nlm.nih.gov/pubmed/11877535
% see comments in above section

trialType = 'doubleStepRamp';
trialDetails = 'txt';
trialRepeats = 50;

%Simulate
[RawData_txt, SummaryData_txt, Params_txt] = Simulate_FullExpt(trialType, trialDetails, trialRepeats);

% Plot_deBrouwer2(SummaryData_deBrouwer, Params_deBrouwer);
Plot_deBrouwer2(SummaryData_txt, Params_txt)
Plot_deBrouwer3(SummaryData_txt, Params_txt)

Plot_SRTdistributions( SummaryData_txt, Params_txt);

%Save
str_timestamp = date;
filename = sprintf('SimData_txt_%g_%s', trialRepeats, str_timestamp);
save(filename, 'RawData_txt', 'SummaryData_txt', 'Params_txt', '-v7.3')


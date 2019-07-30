function [  ] = Plot_bieg( SummaryData_bieg, Params_bieg )
%Plot_bieg Reproduces Figure 2 from Bieg et al 2015 https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4534514/pdf/221_2015_Article_4323.pdf
%   Plots Proportion of Saccadic Trials and Mean Latency for 2:12 deg steps for +/-20, +/-10 deg/s

%Plot SaccProp & SRT
%Params_bieg.TrialParams.trialDetails = 1x3 cell {PSrange; VSrange; 'bieg'}
%SummaryData_bieg.saccMetrics = [latency; duration; peakVel] x trialRepeats x PS x VS
%SummaryData_bieg.conditionSaccMetrics = [SaccProportion; meanSRT; stdSRT] x PS x VS

figure
figN = get(gcf, 'number');
cmap1 = brewermap(3, '*blues');
cmap2 = brewermap(3,'*reds');

subplot(2,2,1)
hold on
VSi = Params_bieg.TrialParams.trialDetails{2} == -20; %foveopetal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(1,:,VSi),sqrt(SummaryData_bieg.conditionSaccMetrics(1,:,VSi).*(1-SummaryData_bieg.conditionSaccMetrics(1,:,VSi))/Params_bieg.TrialParams.trialRepeats ) ,'o-', 'color', cmap1(1,:), 'linewidth', 1)
VSi = Params_bieg.TrialParams.trialDetails{2} == 20; %foveofugal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(1,:,VSi), sqrt(SummaryData_bieg.conditionSaccMetrics(1,:,VSi).*(1-SummaryData_bieg.conditionSaccMetrics(1,:,VSi))/Params_bieg.TrialParams.trialRepeats ) ,'o-', 'color', cmap2(1,:), 'linewidth', 1)
ylabel('Proportion Saccadic Trials')
ylim([0,1])
xlim([0,12])
xticks([0:2:12])
title('|VS|= 20 deg/s')
legend({'petal', 'fugal'})
legend('location', 'east')

subplot(2,2,2)
hold on
VSi = Params_bieg.TrialParams.trialDetails{2} == -10; %foveopetal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(1,:,VSi), sqrt(SummaryData_bieg.conditionSaccMetrics(1,:,VSi).*(1-SummaryData_bieg.conditionSaccMetrics(1,:,VSi))/Params_bieg.TrialParams.trialRepeats ) ,'o-', 'color', cmap1(1,:), 'linewidth', 1)
VSi = Params_bieg.TrialParams.trialDetails{2} == 10; %foveofugal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(1,:,VSi), sqrt(SummaryData_bieg.conditionSaccMetrics(1,:,VSi).*(1-SummaryData_bieg.conditionSaccMetrics(1,:,VSi))/Params_bieg.TrialParams.trialRepeats ) ,'o-', 'color', cmap2(1,:), 'linewidth', 1)
title('|VS|= 10 deg/s')
ylim([0,1])
xlim([0,12])
xticks([0:2:12])


subplot(2,2,3)
hold on
VSi = Params_bieg.TrialParams.trialDetails{2} == -20; %foveopetal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(2,:,VSi), SummaryData_bieg.conditionSaccMetrics(3,:,VSi), 'color', cmap1(1,:), 'marker', 'o', 'linewidth', 1)
VSi = Params_bieg.TrialParams.trialDetails{2} == 20; %foveofugal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(2,:,VSi), SummaryData_bieg.conditionSaccMetrics(3,:,VSi), 'color', cmap2(1,:), 'marker', 'o', 'linewidth', 1)
ylabel('Mean Latency (ms)')
xlabel('Position Step (deg)')
ylim([150, 450])
yticks([150:50:450])
xlim([0,12])
xticks([0:2:12])

subplot(2,2,4)
hold on
VSi = Params_bieg.TrialParams.trialDetails{2} == -10; %foveopetal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(2,:,VSi), SummaryData_bieg.conditionSaccMetrics(3,:,VSi), 'color', cmap1(1,:), 'marker', 'o', 'linewidth', 1)
VSi = Params_bieg.TrialParams.trialDetails{2} == 10; %foveofugal
errorbar(Params_bieg.TrialParams.trialDetails{1}, SummaryData_bieg.conditionSaccMetrics(2,:,VSi), SummaryData_bieg.conditionSaccMetrics(3,:,VSi), 'color', cmap2(1,:), 'marker', 'o', 'linewidth', 1)
xlabel('Position Step (deg)')
ylim([150, 450])
yticks([150:50:450])
xlim([0,12])
xticks([0:2:12])

end


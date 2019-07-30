function [  ] = Plot_SRT_SaccProp( SummaryData, Params, cmap, figN )
%Plot_SRT_SaccProp, 
% given SummaryData and Params, use conditionSaccMetrics to plot 
%SRT, SaccProp vs PS, 


if nargin == 4
    figure(figN)
end

subplot(2,1,1) %Plot SaccProp vs PS
hold on

PSrange = Params.TrialParams.trialDetails{1};
SaccProp = SummaryData.conditionSaccMetrics(1,:,1);
trialRepeats = Params.TrialParams.trialRepeats;
semSaccProp = sqrt(SaccProp.*(1-SaccProp)./trialRepeats);

errorbar(PSrange, SaccProp, semSaccProp, 'color', cmap, 'linewidth', 0.3, 'marker', 'o')
set(gca, 'tickdir', 'out')


subplot(2,1,2)
hold on
meanSRT = SummaryData.conditionSaccMetrics(2,:,1);
stdSRT = SummaryData.conditionSaccMetrics(3,:,1);

errorbar(PSrange, meanSRT, stdSRT, 'color', cmap, 'linewidth', 0.3, 'marker', 'o')
set(gca, 'tickdir', 'out')

end


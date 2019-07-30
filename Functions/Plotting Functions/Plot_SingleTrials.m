function [ legendHandle, legendLabels ] = Plot_SingleTrials( RawData, Params, trialRepeatsPlotted, label, legendHandle, legendLabels )
%Plot_SingleTrials Reproduce Figures 4 & 6 from Coutinho et al., 2018 (bioRXiv)
%   Plots: (Target,Eye), PEsens, RSsens, PEpred, SaccConfidence

nTrialTotal = size(RawData.Eye,3);
if trialRepeatsPlotted < nTrialTotal
    trialNumbers = randi(nTrialTotal,[trialRepeatsPlotted,1]);
else
    trialNumbers = 1:nTrialTotal;
end
colourList = {'*blues', '*reds', '*greys', '*greens', '*purples', '*oranges'};
if ~exist('legendHandle', 'var')
    colourStyle = brewermap(2+trialRepeatsPlotted, '*blues');
else
    colourStyle = brewermap(2+trialRepeatsPlotted, colourList{length(legendHandle) +1});
end

%Reshaping Matrices for ciplot
newDim1 = size(RawData.deltaSens,2);
newDim2 = size(RawData.deltaSens,3);

PEsens = reshape(RawData.deltaSens(1,:,:), [newDim1, newDim2]);
sigPEsens = reshape(RawData.sigSens(1,:,:), [newDim1, newDim2]);

RSsens = reshape(RawData.deltaSens(2,:,:), [newDim1, newDim2]);
sigRSsens = reshape(RawData.sigSens(2,:,:), [newDim1, newDim2]);

PEpred = reshape(RawData.deltaPred(1,:,:), [newDim1, newDim2]);
sigPEpred = reshape(RawData.sigPred(1,:,:), [newDim1, newDim2]);


%
Plot_EyeVel =0;
% Plot_SRTdistributions = 1;
%
extraSubplots = 0;
if Plot_EyeVel ==1
    extraSubplots = extraSubplots + 1;
end
% if Plot_SRTdistributions ==1
%     totalSubplots = 5;
% end
totalSubplots = 5 + extraSubplots;
if strcmpi(Params.TrialParams.trialType, 'doubleStepRamp')
    tvect = Params.TrialParams.tvect2;
else
    tvect = Params.TrialParams.tvect;
end

for trialInd = 1:trialRepeatsPlotted
    
    trial = trialNumbers(trialInd);
    subplotIndex = 1;   %counter for variable subplot numbers

    %EyePos vs Time (and TarPos vs Time)
    subplot(totalSubplots,1,subplotIndex)
    hold on
    if trialInd ==1
        if ~exist('legendHandle', 'var')
            legendHandle(1) = plot(tvect, RawData.Eye(1,:,trial), 'color', colourStyle(trialInd,:), 'linewidth', 1.5);
        else
            legendHandle(1+ length(legendHandle)) = plot(tvect, RawData.Eye(1,:,trial), 'color', colourStyle(trialInd,:), 'linewidth', 1.5);
        end
    else
        plot(tvect, RawData.Eye(1,:,trial), 'color', colourStyle(trialInd,:), 'linewidth', 1.5)
    end
    subplotIndex = subplotIndex+1;
    
    if Plot_EyeVel ==1
       %EyeVel vs Time
       subplot(totalSubplots, 1, subplotIndex)
       hold on
       plot(tvect, RawData.Eye(2,:,trial), 'color', colourStyle(trialInd,:), 'linewidth', 1.5);
       subplotIndex = subplotIndex+1;
    end
    
    %PEsens vs Time
    subplot(totalSubplots,1,subplotIndex)
    hold on
    ciplot(PEsens(:,trial)+sqrt(sigPEsens(:,trial)), PEsens(:,trial)-sqrt(sigPEsens(:,trial)), tvect, colourStyle(trialInd,:))
    subplotIndex = subplotIndex+1;
    
    %RSsens vs Time
    subplot(totalSubplots,1,subplotIndex)
    hold on
    ciplot(RSsens(:,trial)+ sqrt(sigRSsens(:,trial)), RSsens(:,trial) - sqrt(sigRSsens(:,trial)), tvect, colourStyle(trialInd,:))
    subplotIndex=subplotIndex+1;
    
    %PEpred vs time
    subplot(totalSubplots,1,subplotIndex)
    hold on
    ciplot(PEpred(:,trial)+sqrt(sigPEpred(:,trial)), PEpred(:,trial)-sqrt(sigPEpred(:,trial)), tvect, colourStyle(trialInd,:))
    subplotIndex = subplotIndex+1;
    
    %LLR vs Time
    subplot(totalSubplots,1,subplotIndex)
    hold on
    plot(tvect, RawData.LLRsacc(1,:,trial), 'color', colourStyle(trialInd,:), 'linewidth', 1)
    subplotIndex = subplotIndex+1;

end
% Plot Formatting
subplotIndex = 1;
dt = 0.001;     %[s]
delay = 70;     %[ms]

%Eye Pos vs Time
subplot(totalSubplots,1,subplotIndex)
hold on
plot(tvect, RawData.TargetMotion(1,:), 'k--', 'linewidth', 2);
plot([dt*delay, dt*delay], ylim, 'k:')
plot([0,0], ylim, 'k:')
ylabel('Position (deg)')
xlim([-0.1, 0.4]);
if ~exist('legendLabels', 'var')
    legendLabels{1} = label;
else
    legendLabels{1+length(legendLabels)} = label;
end
legend('location', 'best')
legend(legendHandle, legendLabels )
set(gca,'TickDir','out'); % The only other option is 'in'
subplotIndex = subplotIndex+1;


if Plot_EyeVel ==1
%EyeVel vs Time
subplot(totalSubplots, 1, subplotIndex)
plot(tvect, RawData.TargetMotion(2,:), 'k--', 'linewidth', 2);
plot([dt*delay, dt*delay], ylim, 'k:')
plot([0,0], ylim, 'k:')
ylabel('EyeVel (deg/s)')
xlim([-0.1,0.4])
ylim([-10,50])
set(gca,'TickDir','out'); % The only other option is 'in'
subplotIndex = subplotIndex+1;
end

%PEsens vs time
subplot(totalSubplots,1,subplotIndex)
hold on
% plot(tvect,TargetMotionSacc(2,:), 'r--', 'linewidth', 2)
% plot(tvect,TargetMotionSmooth(2,:), 'b--', 'linewidth', 2)
% sublegend2{end+1} = sprintf('target');
plot([dt*delay, dt*delay], ylim, 'k:')
plot([0,0], ylim, 'k:')
ylabel('PEsens (deg)')
xlim([-0.1, 0.4]);
set(gca,'TickDir','out'); % The only other option is 'in'
subplotIndex = subplotIndex+1;

% legend(sublegend2)
% legend('location', 'best')

%RSsens vs time
subplot(totalSubplots,1,subplotIndex)
plot(tvect, RawData.TargetMotion(2,:), 'k--', 'linewidth', 2);
plot([dt*delay, dt*delay], ylim, 'k:')
plot([0,0], ylim, 'k:')
hold on
ylabel('RSsens (deg/s)')
xlim([-0.1, 0.4]);
set(gca,'TickDir','out'); % The only other option is 'in'
subplotIndex = subplotIndex+1;

%PEpred vs time
subplot(totalSubplots,1,subplotIndex)
hold on
plot(tvect, zeros(size(tvect)), 'k--', 'linewidth', 1)
plot([dt*delay, dt*delay], ylim, 'k:')
plot([0,0], ylim, 'k:')
xlim([-0.1, 0.4])
ylabel('PEpred (deg)')
set(gca,'TickDir','out'); % The only other option is 'in'
subplotIndex = subplotIndex+1;

%Sacc Confidence vs Time
subplot(totalSubplots,1,subplotIndex)
hold on
plot(tvect, Params.DecisionParams.saccThresh.*ones(size(tvect)), 'k--', 'linewidth', 1)
plot(tvect, -Params.DecisionParams.saccThresh.*ones(size(tvect)), 'k--', 'linewidth', 1)
plot([dt*delay, dt*delay], ylim, 'k:')
plot([0,0], ylim, 'k:')
xlim([-0.1, 0.4])
subtitle = sprintf('Confidence: \nLog Probability Ratio');
ylabel(subtitle)
xlabel('Time (s)')
set(gca,'TickDir','out'); % The only other option is 'in'

set(gcf, 'position', [1375, 9, 538, 988])


end


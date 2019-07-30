function [ figN ] = Plot_deBrouwer2( SummaryData_deBrouwer, Params_deBrouwer )
%Plot_deBrouwer Plots Fig 3 from de Brouwer et al 2002
%   SaccProp and SRT vs Txe separated by change in speed. 

SR1length = length(Params_deBrouwer.TrialParams.trialDetails{1});
VSlength = length(Params_deBrouwer.TrialParams.trialDetails{3});
cmap = brewermap(5, '*greys');
% figure
% hold on
% figN = get(gcf, 'number');

binSize = 0.05;
TxeBins = -0.3 : binSize : 0.5;

figure
figN = get(gcf, 'number');
for iSpeed = 1:3    
    if strcmpi(Params_deBrouwer.TrialParams.trialDetails{4}, 'deBrouwer') %VSrange = [-50:10:50];
        if iSpeed ==1
            VSrange = [5,7];    %VS = -10, 10
        elseif iSpeed ==2
            VSrange = [4,8];    %VS = -20, 20
        elseif iSpeed ==3
            VSrange = [2,10];   %VS = -40, 40, these are based on 
        end
    else    %'txt', VSrange =[-40, -20, -10, 10, 20, 40]; 
        if iSpeed ==1
            VSrange = [3,4];
        elseif iSpeed ==2
            VSrange = [2,5];
        elseif iSpeed ==3
            VSrange = [1,6];
        end
    end
    for iTxe = 1:length(TxeBins)-1
        nSacc = 0;
        nTotal = 0;
        SRT = [];
        Txe = [];
        
        
        
        for VSi =VSrange
            
            
            for SR1i = 1:SR1length
                
                VS = Params_deBrouwer.TrialParams.trialDetails{3}(VSi);
                if strcmpi(Params_deBrouwer.TrialParams.trialDetails, 'deBrouwer')
                    if VS < -10
                        PSlength = length(Params_deBrouwer.TrialParams.trialDetails{2}(1,:));
                    elseif VS >10
                        PSlength = length(Params_deBrouwer.TrialParams.trialDetails{2}(3,:));
                    else
                        PSlength = 11;%length(Params_deBrouwer.TrialParams.trialDetails{2}(2,:));
                    end
                else
                    PSlength = length(Params_deBrouwer.TrialParams.trialDetails{2});
                end
                
                for PSi = 1:PSlength
                    

                    %gives index of trials with appropriate Txe within (PSi, VSi, SR1i) condition
                    correctTrials = SummaryData_deBrouwer.detMetrics2(3,:,PSi,VSi,SR1i) > TxeBins(iTxe) & SummaryData_deBrouwer.detMetrics2(3,:,PSi,VSi,SR1i) < TxeBins(iTxe+1);
                    
                    Txe = [Txe, SummaryData_deBrouwer.detMetrics2(3,correctTrials,PSi,VSi,SR1i)];
                    SRT = [SRT, SummaryData_deBrouwer.saccMetrics2(1,correctTrials,PSi, VSi, SR1i)];
                    nSacc = nSacc + sum(~isnan(SummaryData_deBrouwer.saccMetrics2(1,correctTrials,PSi, VSi, SR1i)));
                    nTotal = nTotal + sum(correctTrials);
                    
%                     drawnow 
                end
                
            end
        end     %end of loop over conditions
        
        meanTxe(iTxe, iSpeed) = mean(Txe, 'omitnan');
        
        meanSRT(iTxe, iSpeed) = mean(SRT, 'omitnan');
        stdSRT(iTxe, iSpeed) = std(SRT, 0, 'omitnan');
        if nTotal >0
            meanSaccProp(iTxe, iSpeed) = nSacc/nTotal;
            semSaccProp(iTxe, iSpeed) = sqrt( (nSacc/nTotal).*(1-nSacc/nTotal)) / sqrt(nTotal);
        else
            meanSaccProp(iTxe, iSpeed) = nan;
            semSaccProp(iTxe, iSpeed) = nan;
        end
        
        figure(figN)
        hold on
        subplot(2,1,2)
        plot(TxeBins(iTxe), nTotal, 'o-', 'color', cmap(iSpeed,:))  %sanity check that Txe are fairly sampled
    end     %end of loop over TxeBins
    
    figure(figN)    %Plots meanTxe for each bin (sanity check that Txe is fairly evaluated)
    subplot(2,1,1)
    hold on
    plot(TxeBins(1:end-1), meanTxe(:,iSpeed), 'o-')
    
end %end of loop over iSpeed

figure(figN)
subplot(2,1,1)
hold on
plot(TxeBins(1:end-1),TxeBins(1:end-1), 'k--')

figure
subplot(2,1,1)  %Saccade proportion vs Txe
hold on
xAxis = TxeBins(1:end-1)+binSize/2;
for iSpeed = 1:3
    ind = ~isnan(meanSaccProp(:,iSpeed));
errorbar(xAxis(ind) + (iSpeed-1)*0.005, meanSaccProp(ind,iSpeed), semSaccProp(ind,iSpeed), '-o', 'color', cmap(iSpeed,:), 'linewidth', 0.8);
end
xlim([TxeBins(1), TxeBins(end)])
ylim([0,1])
plot([0.04,0.04], ylim, 'k--', 'linewidth', 1)
plot([0.18,0.18], ylim, 'k--', 'linewidth', 1)
set(gca,'TickDir','out'); % The only other option is 'in'
ylabel('Sacc Proportion')
legend({'VS=10', 'VS=20', 'VS=40'})


subplot(2,1,2)  %mean saccade trigger time vs Txe
hold on
errorbar(xAxis, meanSRT(:,1), stdSRT(:,1), [], '-o', 'color', cmap(1,:), 'linewidth', 0.8)
errorbar(xAxis+0.005, meanSRT(:,2), [], stdSRT(:,2), '-o', 'color', cmap(2,:), 'linewidth', 0.8)
errorbar(xAxis+0.01, meanSRT(:,3), [], stdSRT(:,3), '-o', 'color', cmap(3,:), 'linewidth', 0.8)
xlim([TxeBins(1), TxeBins(end)])
ylim([100, 400])
plot([0.04,0.04], ylim, 'k--', 'linewidth', 1)
plot([0.18,0.18], ylim, 'k--', 'linewidth', 1)
set(gca,'TickDir','out'); % The only other option is 'in'
xlabel('T_X_E (s)')
ylabel('Mean Latency (ms)')





end


function [ figN ] = Plot_deBrouwer3( SummaryData_deBrouwer, Params_deBrouwer )
%Plot_deBrouwer Plots Fig 3 from de Brouwer et al 2002
%   SaccProp and SRT vs Txe separated by absolute speed.

SR1length = length(Params_deBrouwer.TrialParams.trialDetails{1});
VSlength = length(Params_deBrouwer.TrialParams.trialDetails{3});
% figure
% hold on
% figN = get(gcf, 'number');
% 
% binSize = 0.05;
% TxeBins = -0.3 : binSize : 0.7;

figure
figN = get(gcf,'number');


for flag = 1:2
    for VSi = 1:VSlength
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
                
                ind = SummaryData_deBrouwer.saccMetrics2(1,:,PSi,VSi,SR1i)>300;
                figure(figN)
                subplot(2,1,1)
                hold on
                if flag ==1
                    plot(SummaryData_deBrouwer.sensMetrics2(1,~ind,PSi, VSi, SR1i), SummaryData_deBrouwer.sensMetrics2(2,~ind,PSi,VSi,SR1i), 'marker', '.', 'color', 0.5*ones(1,3), 'linestyle', 'none')
                else
                    plot(SummaryData_deBrouwer.sensMetrics2(1,ind,PSi, VSi, SR1i), SummaryData_deBrouwer.sensMetrics2(2,ind,PSi,VSi,SR1i), 'marker', '.', 'color', 0*ones(1,3), 'linestyle', 'none')
                end
                
                subplot(2,1,2)
                hold on
                if flag ==1
                    plot(SummaryData_deBrouwer.detMetrics2(1,~ind,PSi, VSi, SR1i), SummaryData_deBrouwer.sensMetrics2(2,~ind,PSi,VSi,SR1i), 'marker', '.', 'color', 0.5*ones(1,3), 'linestyle', 'none')
                else
                    plot(SummaryData_deBrouwer.detMetrics2(1,ind,PSi, VSi, SR1i), SummaryData_deBrouwer.sensMetrics2(2,ind,PSi,VSi,SR1i), 'marker', '.', 'color', 0*ones(1,3), 'linestyle', 'none')
                end
                
                
                
                %gives index of trials with appropriate Txe within (PSi, VSi, SR1i) condition
                %                     correctTrials = SummaryData_deBrouwer.detMetrics2(3,:,PSi,VSi,SR1i) > TxeBins(iTxe) & SummaryData_deBrouwer.detMetrics2(3,:,PSi,VSi,SR1i) < TxeBins(iTxe+1);
                %
                %                     Txe = [Txe, SummaryData_deBrouwer.detMetrics2(3,correctTrials,PSi,VSi,SR1i)];
                %                     SRT = [SRT, SummaryData_deBrouwer.saccMetrics2(1,correctTrials,PSi, VSi, SR1i)];
                %                     nSacc = nSacc + sum(~isnan(SummaryData_deBrouwer.saccMetrics2(1,correctTrials,PSi, VSi, SR1i)));
                %                     nTotal = nTotal + sum(correctTrials);
                %
                drawnow
            end
            
        end
    end     %end of loop over conditions
    
end

subplot(2,1,1)
x = -20:0.1:20;
y1 = -x./0.04;
y2 = -x./0.18;
plot(x,y1,'k', 'linewidth', 1.5)
plot(x,y2, 'k', 'linewidth', 1.5)
xlim([-20,20])
ylim([-60,60])
ylabel('RSsens (deg/s)')
xlabel('PEsens (deg)')
set(gca, 'tickdir', 'out');

subplot(2,1,2)
x = -20:0.1:20;
y1 = -x./0.04;
y2 = -x./0.18;
plot(x,y1,'k', 'linewidth', 1.5)
plot(x,y2, 'k', 'linewidth', 1.5)
xlim([-20,20])
ylim([-60,60])
ylabel('RSdet (deg/s)')
xlabel('PEdet (deg)')
set(gca, 'tickdir', 'out');


end


function [ output_args ] = Plot_SRTdistributions(  SummaryData, Params )
%Plot_SRTdistributions Plots full distributions of saccade trigger time sorted by Txt


%% Plotting SRT Distributions
% Plots SRT distributions based on pos, neg, mid Txt

%SummaryData.saccMetrics2 = [SRT; duration; peakVel] has size [3 x trialRepeats x PSlength x VSlength x SR1length]
VSlength = size(Params.TrialParams.trialDetails{3},2);
SR1length = size(Params.TrialParams.trialDetails{1},2);

[SRTneg, SRTmid, SRTpos] = deal(cell(1,2));

%Separating Pos vs Neg VS2
flag_splitVS = 0;

for VSi = 1:VSlength
    
    VS = Params.TrialParams.trialDetails{3}(VSi);
    
    %Determine (PSrange,PSlength, txtRange) for given VS
    if strcmpi(Params.TrialParams.trialDetails{4}, 'txt')  %trialDetails{2} = txtRange
        txtRange = Params.TrialParams.trialDetails{2};
        PSlength = length(txtRange);
        
    elseif strcmpi(Params.TrialParams.trialDetails{4}, 'deBrouwer')    %trialDetails{2} = PSrange, varies depending on VS
        if VS < -10
            PSrange = Params.TrialParams.rialDetails{2}(1,:);
        elseif VS >10
            PSrange = Params.TrialParams.trialDetails{2}(3,:);
        else
            PSrange = Params.TrialParams.trialDetails{2}(2,:);
        end
        
        PSlength = sum(~isnan(PSrange));
    end
    
    for PSi = 1:PSlength
        
        if strcmpi(Params.TrialParams.trialDetails{4}, 'txt')
            Txt = Params.TrialParams.trialDetails{2}(PSi);
        else
            PS = PSrange(PSi);
            Txt = -PS./VS;
        end
        
        for SR1i = 1:SR1length
            if flag_splitVS ==1
                if VS<0
                    if Txt > 0.4
                        SRTpos{1} = [SRTpos{1}; SummaryData.saccMetrics2(1,:,PSi, VSi, SR1i)'];    %current index SRT' should give column vector
                    elseif Txt <0
                        SRTneg{1} = [SRTneg{1}; SummaryData.saccMetrics2(1,:,PSi, VSi, SR1i)'];
                    else
                        SRTmid{1} = [SRTmid{1}; SummaryData.saccMetrics2(1,:,PSi,VSi,SR1i)'];
                    end
                elseif VS>0
                    if Txt > 0.4
                        SRTpos{2} = [SRTpos{2}; SummaryData.saccMetrics2(1,:,PSi, VSi, SR1i)'];    %current index SRT' should give column vector
                    elseif Txt <0
                        SRTneg{2} = [SRTneg{2}; SummaryData.saccMetrics2(1,:,PSi, VSi, SR1i)'];
                    else
                        SRTmid{2} = [SRTmid{2}; SummaryData.saccMetrics2(1,:,PSi,VSi,SR1i)'];
                    end
                end
            else        %if flag_splitVS ==0
                if Txt > 0.4
                    SRTpos{1} = [SRTpos{1}; SummaryData.saccMetrics2(1,:,PSi, VSi, SR1i)'];    %current index SRT' should give column vector
                elseif Txt <0
                    SRTneg{1} = [SRTneg{1}; SummaryData.saccMetrics2(1,:,PSi, VSi, SR1i)'];
                else
                    SRTmid{1} = [SRTmid{1}; SummaryData.saccMetrics2(1,:,PSi,VSi,SR1i)'];
                end
               
            end
        end
    end
end

if flag_splitVS ==1
    BinEdges = 100:10:500;
    figure
    subplot(2,3,1)
    histogram(SRTneg{1}, BinEdges, 'normalization', 'probability')
    subtitle = sprintf('Negative VS2 \nTxt<0 [s] \nN=%g', numel(SRTneg{1}));
    title(subtitle)
    ylabel('Proportion Saccadic Trials')
    
    subplot(2,3,2)
    histogram(SRTmid{1}, BinEdges, 'normalization', 'probability')
    subtitle = sprintf('0<Txt<0.4 [s] \n(N=%g)', numel(SRTmid{1}));
    title(subtitle)
    
    subplot(2,3,3)
    histogram(SRTpos{1}, BinEdges, 'normalization', 'probability')
    subtitle = sprintf('Txt>0.4 [s]\n(N=%g)', numel(SRTpos{1}));
    title(subtitle)
    
    subplot(2,3,4)
    histogram(SRTneg{2}, BinEdges, 'normalization', 'probability')
    subtitle = sprintf('Positive VS2 \nTxt<0 [s]\n(N=%g)', numel(SRTneg{2}));
    title(subtitle)
    xlabel('SRT (ms)')
    ylabel('Proportion Saccadic Trials')
    
    subplot(2,3,5)
    histogram(SRTmid{2}, BinEdges, 'normalization', 'probability')
    subtitle = sprintf('0<Txt<0.4 [s]\n(N=%g)', numel(SRTmid{2}));
    title(subtitle)
    xlabel('SRT (ms)')
    
    subplot(2,3,6)
    histogram(SRTpos{2}, BinEdges, 'normalization', 'probability')
    subtitle = sprintf('Txt>0.4 [s]\n(N=%g)', numel(SRTpos{2}));
    title(subtitle)
    xlabel('SRT (ms)')
else
    BinEdges = 100:15:500;
    figure
    subplot(3,1,1)
    histogram(SRTneg{1}, BinEdges, 'normalization', 'probability',  'FaceColor', 'k')
    subtitle = sprintf('Txt<0 [s]\n(N=%g)', numel(SRTneg{1}));
    title(subtitle)
    ylabel('Proportion Saccadic Trials')
    xlabel('SRT (ms)')
    xlim([100, 450])
    ylim([0,0.3])
    
    subplot(3,1,2)
    histogram(SRTmid{1}, BinEdges, 'normalization', 'probability',  'FaceColor', 'k')
    subtitle = sprintf('0<Txt<0.4 [s] \n(N=%g)', numel(SRTmid{1}));
    title(subtitle)
    xlabel('SRT (ms)')
    xlim([100, 450])
    ylim([0,0.3])
    
    subplot(3,1,3)
    histogram(SRTpos{1}, BinEdges, 'normalization', 'probability',  'FaceColor', 'k')
    subtitle = sprintf('Txt>0.4 [s]\n(N=%g)', numel(SRTpos{1}));
    title(subtitle)
    xlabel('SRT (ms)')
    xlim([100, 450])
    ylim([0,0.3])
    
end
    


end


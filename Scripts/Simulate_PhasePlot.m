%% Estimating Saccade Confidence evolution

% JD Coutinho, P Lefevre, G Blohm 2019 (j.coutinho@queensu.ca)
% Confidence in predicted position error explains saccadic decisions during pursuit
% doi: https://doi.org/10.1101/396788

%% Specify noise parameters
KalmanParams = Initialize_KalmanParams;
DecisionParams = Initialize_DecisionParams; %Default params.

%Specify Signal Range (to cover phase plot)
VSrange = -50:2:50;
PSrange = -20:20;   
trialRepeat = 100;

dt = 0.001;
tvect = [1:500]*dt;

% This is very similar to Simulate_VisTracking.m (expedited)
[predMean, predVar, RSsens, RSsensVar, PEsens, PEsensVar] = deal(nan(length(PSrange),length(VSrange),length(tvect)));

for VSi = 1:length(VSrange)
    for PSi = 1:length(PSrange)
        %Initialize Signals
        signal = zeros(2,length(tvect),trialRepeat); %[PS;VS , time.......]
        signal_est = zeros(2,length(tvect), trialRepeat);
        signal_var = zeros(2,length(tvect), trialRepeat);
        signal_var(:,1,:) = 1;
        
        for trial = 1:trialRepeat
            Evect = [0;0;0;0];
            EyePos = 0;
            for k = 1: (length(tvect)-1)
                
                if k ==100
                    %Generate Step Ramp
                    signal(:,k+1,trial) = [PSrange(PSi); VSrange(VSi)];
                else
                    %Generate signal evolution
                    A = [1, dt; 0, 1];
                    signal(:,k+1,trial) = A*signal(:,k,trial);
                end
                
                %Estimate signals through Kfilt.
                EyePos = EyePos + dt*Evect(1);
                [signal_est(1,k+1,trial), signal_var(1,k+1,trial)] = KalmanFilter2_PE(signal(1,k) - EyePos, signal_est(1,k,trial), signal_var(1,k,trial), KalmanParams);
                [signal_est(2,k+1,trial), signal_var(2,k+1,trial)] = KalmanFilter2_RS(signal(2,k) - Evect(1), signal_est(2,k,trial), signal_var(2,k,trial), KalmanParams);
                
                
                %Prediction
                [pred(k+1,trial), sigPred(k+1,trial)] = PEpredict(signal_est(1,k,trial), signal_var(1,k,trial), signal_est(2,k,trial), signal_var(2,k,trial), DecisionParams.RSdelT);
                
                
                %Pursuit
                Evect = PursuitMotionPathway(Evect, signal_est(2,k,trial), 0.9);
                
            end         %end of loop over time
            
            
        end %end of loop over trial Repeats
        
        %Take average estimated variance across trialRepeats
        predMean(PSi,VSi,:) = mean(pred,2, 'omitnan');
        predVar(PSi,VSi,:) = mean(sigPred,2, 'omitnan');
        
        PEsens(PSi,VSi,:) = mean(signal_est(1,:,:), 3, 'omitnan');
        PEsensVar(PSi,VSi,:) = mean(signal_var(1,:,:),3, 'omitnan');
        
        RSsens(PSi,VSi,:) = mean(signal_est(2,:,:), 3, 'omitnan');
        RSsensVar(PSi,VSi,:) = mean(signal_var(2,:,:), 3, 'omitnan');
    end
end  %end of loop over VSrange
str_timestamp = date;
filename = sprintf('SaccConfidencePhaseplot_%s.mat', str_timestamp);
cd('E:\OneDrive - Queen''s University\Basic Simulations\Saccade Trigger Model Final\Simulation Data\Current')
save(filename, 'predVar', 'predMean', 'PEsens', 'PEsensVar', 'RSsens', 'RSsensVar', 'VSrange', 'PSrange', '-v7.3', '-nocompression')
cd('E:\OneDrive - Queen''s University\Basic Simulations\Saccade Trigger Model Final')



%% Binning for PE, RS
LLRsmooth = nan(length(PSrange)-1, length(VSrange)-1, 500);     %Leaky integrated saccade confidence

for PSi = 1:length(PSrange)-1
    for VSi = 1:length(VSrange)-1
        LLRsmooth(PSi,VSi,1) = 0;
        
        for k = 1:500-1
            % Which indices fit this sensory (PE,RS)?
            indPE = PEsens(:,:,k) > PSrange(PSi) & PEsens(:,:,k) < PSrange(PSi+1);
            indRS = RSsens(:,:,k) > VSrange(VSi) & RSsens(:,:,k) < VSrange(VSi+1);
            ind = indPE & indRS;
            
            pePred = predMean(:,:,k);
            pePred = pePred(ind);
            pePred = mean(pePred, 'omitnan');
            
            pePredVar = predVar(:,:,k);
            pePredVar = pePredVar(ind);
            pePredVar = mean(pePredVar, 'omitnan');
            
            if ~isnan(pePred)   %typical
                pL = normcdf(0,pePred, pePredVar);
                LLR(PSi,VSi,k) = log(pL./(1-pL));   %Saccade Confidence
            else 
                pL = 0.5;
                LLR(PSi,VSi,k) = log(pL./(1-pL));
            end
            
            %Leaky Integration
            LLRsmooth(PSi,VSi,k+1) = LeakyIntegrator(LLR(PSi,VSi,k), LLRsmooth(PSi,VSi,k), DecisionParams.decisionTau);
            
        end
    end
end


figure
trialInd = [17, 19, 17, 19, 27, 29, 9;...
    36, 31, 16, 21, 16, 16, 46];
%Corresponding stepramps
%          [-4 -2 -4 -2    6   8 -12; ...
%           20 10 -20 -10 -20  -20  40]
subplotInd =1;
trange = [150 200 250];

for i = trange
    %     if i == length(trange)-2
    %         figure
    %         subplotInd = 1;
    %     end
    subplot(3,1,subplotInd)
    hold on
    contour(PSrange(1:end-1), VSrange(1:end-1), abs(LLRsmooth(:,:,i)'), [0:5])
    for q = 1:length(trialInd)
        pe(:) = PEsens(trialInd(1,q), trialInd(2,q), 150:i);
        rs(:) = RSsens(trialInd(1,q), trialInd(2,q), 150:(i));
        plot(pe, rs, 'k-')
        if q<3
            plot(pe(1), rs(1), 'kd')
        elseif q<5
            plot(pe(1), rs(1), 'rd')
        else
            plot(pe(1), rs(1), 'bd')
        end
        
        clear pe rs
    end
    grid on
    subtitle = sprintf('Time after step = %i ms', (i-100));
    title(subtitle)
    colorbar('ticks', [0:5])
    caxis([0 5])
    x = -20:0.1:20;
    y1 = -x./0.04;
    y2 = -x./0.18;
    plot(x,y1,'k', 'linewidth', 1.5)
    plot(x,y2, 'k', 'linewidth', 1.5)
    xlim([-20,20])
    ylim([-60,60])
    subplotInd = subplotInd+1;
end
xlabel('PSsens (deg)')
ylabel('RSsens (deg/s)')


%% Plot Mean Sacc Confidence contours
averagingWindow = 150:250;  %Take average Sacc Confidence

h = figure(10);
hold on
contour(PSrange(1:end-1), VSrange(1:end-1), abs(mean(LLRsmooth(:,:,averagingWindow),3))', [0:5])
cmap = inferno(10);
h.Colormap = [cmap(1:6,:); cmap(8:10,:)];
colorbar

x = -20:0.1:20;
y1 = -x./0.04;
y2 = -x./0.18;
plot(x,y1,'k--', 'linewidth', 1.5)
plot(x,y2, 'k--', 'linewidth', 1.5)
xlim([-20,20])
ylim([-60,60])

%plot single trials on phase plot
%smooth
PS=4; VS=-20;
[target, trialParams] = Simulate_TargetMotion2('singleStepRamp', [PS, VS]);
Params = Initialize_DefaultTriggerModel;
Params.TrialParams = trialParams;
[smoothRaw, smoothSummary] = Simulate_VisTracking(target, Params, 1);
figure(10)
hold on
plot(smoothRaw.deltaDet(1,200), smoothRaw.deltaDet(2,200), 'ko', 'linewidth', 1)
if ~isnan(smoothSummary.saccMetrics(1))
    plot(smoothRaw.deltaDet(1,200:(200+smoothSummary.saccMetrics(1))), smoothRaw.deltaDet(2,200:end), 'k', 'linewidth', 1)
    plot(smoothRaw.deltaDet(1,200), smoothRaw.deltaDet(2,200), 'ko', 'linewidth', 1)
else
    plot(smoothRaw.deltaDet(1,200:end), smoothRaw.deltaDet(2,200:end), 'k', 'linewidth', 1)
end

%early saccadfe
PS = 4; VS = 20;
[target, trialParams] = Simulate_TargetMotion2('singleStepRamp', [PS, VS]);
Params = Initialize_DefaultTriggerModel;
Params.TrialParams = trialParams;
[earlySaccRaw, earlySaccSummary] = Simulate_VisTracking(target, Params, 1);
figure(10)
hold on
plot(earlySaccRaw.deltaDet(1,200), earlySaccRaw.deltaDet(2,200),'ro', 'linewidth', 1 )
if ~isnan(earlySaccSummary.saccMetrics(1))
    plot(earlySaccRaw.deltaDet(1,200:(200+earlySaccSummary.saccMetrics(1))), earlySaccRaw.deltaDet(2,200:(200+earlySaccSummary.saccMetrics(1))),'r', 'linewidth', 1 )
    plot(earlySaccRaw.deltaDet(1,(200+earlySaccSummary.saccMetrics(1))), earlySaccRaw.deltaDet(2,(200+earlySaccSummary.saccMetrics(1))),'rd', 'linewidth', 1 )
else
    plot(earlySaccRaw.deltaDet(1,200:end), earlySaccRaw.deltaDet(2,200:end),'r', 'linewidth', 1 )
end
%late saccade
PS = 7; VS = -20;
[target, trialParams] = Simulate_TargetMotion2('singleStepRamp', [PS, VS]);
Params = Initialize_DefaultTriggerModel;
Params.TrialParams = trialParams;
[lateSaccRaw, lateSaccSummary] = Simulate_VisTracking(target, Params, 1);
figure(10)
hold on
if ~isnan(lateSaccSummary.saccMetrics(1))
    plot(lateSaccRaw.deltaDet(1,200), lateSaccRaw.deltaDet(2,200),'bo', 'linewidth', 1 )
    
    plot(lateSaccRaw.deltaDet(1,200:(200+lateSaccSummary.saccMetrics(1))), lateSaccRaw.deltaDet(2,200:(200+lateSaccSummary.saccMetrics(1))),'b', 'linewidth', 1 )
    plot(lateSaccRaw.deltaDet(1,(200+lateSaccSummary.saccMetrics(1))), lateSaccRaw.deltaDet(2,(200+lateSaccSummary.saccMetrics(1))),'bd', 'linewidth', 1 )
else
    plot(lateSaccRaw.deltaDet(1,200), lateSaccRaw.deltaDet(2,200),'ko', 'linewidth', 1 )
    plot(lateSaccRaw.deltaDet(1,200:end), lateSaccRaw.deltaDet(2,200:end),'k', 'linewidth', 1 )
end
% %late sacc 2
% PS = -15; VS = 40;
% [target, trialParams] = Simulate_TargetMotion2('singleStepRamp', [PS, VS]);
% Params = Initialize_DefaultTriggerModel;
% Params.TrialParams = trialParams;
% [lateSaccRaw2, lateSaccSummary2] = Simulate_VisTracking(target, Params, 1);
% figure(10)
% hold on
% if ~isnan(lateSaccSummary2.saccMetrics(1)) && lateSaccSummary2.saccMetrics(1)<500
%     plot(lateSaccRaw2.deltaDet(1,200:(200+lateSaccSummary2.saccMetrics(1))), lateSaccRaw2.deltaDet(2,200:(200+lateSaccSummary2.saccMetrics(1))),'b', 'linewidth', 1 )
%     plot(lateSaccRaw2.deltaDet(1,(200+lateSaccSummary2.saccMetrics(1))), lateSaccRaw2.deltaDet(2,(200+lateSaccSummary2.saccMetrics(1))),'bd', 'linewidth', 1 )
%     plot(lateSaccRaw2.deltaDet(1,200), lateSaccRaw2.deltaDet(2,200),'bo', 'linewidth', 1 )
%     
% else
%     plot(lateSaccRaw2.deltaDet(1,200), lateSaccRaw2.deltaDet(2,200),'ko', 'linewidth', 1)
%     plot(lateSaccRaw2.deltaDet(1,200:end), lateSaccRaw2.deltaDet(2,200:end),'k', 'linewidth', 1)
%     
% end

%maybe sacc
PS = -10; VS = 40;
[target, trialParams] = Simulate_TargetMotion2('singleStepRamp', [PS, VS]);
Params = Initialize_DefaultTriggerModel;
Params.TrialParams = trialParams;
[lateSaccRaw3, lateSaccSummary3] = Simulate_VisTracking(target, Params, 1);
figure(10)
hold on
if ~isnan(lateSaccSummary3.saccMetrics(1)) && lateSaccSummary3.saccMetrics(1)<500
    plot(lateSaccRaw3.deltaDet(1,200:(200+lateSaccSummary3.saccMetrics(1))), lateSaccRaw3.deltaDet(2,200:(200+lateSaccSummary3.saccMetrics(1))),'b', 'linewidth', 1 )
    plot(lateSaccRaw3.deltaDet(1,(200+lateSaccSummary3.saccMetrics(1))), lateSaccRaw3.deltaDet(2,(200+lateSaccSummary3.saccMetrics(1))),'bd', 'linewidth', 1 )
    plot(lateSaccRaw3.deltaDet(1,200), lateSaccRaw3.deltaDet(2,200),'bo', 'linewidth', 1 )
    
else
    plot(lateSaccRaw3.deltaDet(1,200), lateSaccRaw3.deltaDet(2,200),'ko', 'linewidth', 1 )
    plot(lateSaccRaw3.deltaDet(1,200:end), lateSaccRaw3.deltaDet(2,200:end),'k', 'linewidth', 1 )
    
end

grid on
set(gca, 'tickdir', 'out')
xlabel('Position Error (deg)')
ylabel('Retinal Slip (deg/s)')
xlim([-16, 16])
ylim([-41, 41])

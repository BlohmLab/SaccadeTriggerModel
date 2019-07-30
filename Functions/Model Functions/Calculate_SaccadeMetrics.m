function [ Metrics ] = Calculate_SaccadeMetrics( Sacc, onset )
%Find_SaccadeMetrics Metrics = [latency; duration; peakVel]

%Sacc has size [3 x exptDur]
% onset needed to find latency and duration

peakVel = max(Sacc(2,:));
exptDur = length(Sacc);

    for k = 1:exptDur
        if Sacc(3,k) >500       % Detect saccade onset via acceleration threshold
            latency = k - onset;
            break
        end
    end

    for k = exptDur:-1:1
        if Sacc(3,k) < -500     % Detect saccade offset by decel thresh. 
            duration = k - latency - onset;
            break
        end
    end
    
    if ~exist('duration', 'var')
        duration = 5;
    end
    
    
    Metrics = [latency; duration; peakVel];
end


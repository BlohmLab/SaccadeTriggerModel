function [ Metrics ] = Find_SaccadeMetrics2( Sacc, onset )
%Find_SaccadeMetrics Metrics = [latency; duration; peakVel]

%Sacc has size [3 x exptDur]
% onset needed to find latency and duration

peakVel = max(abs(Sacc(2,:)));
exptDur = length(Sacc);


SaccDiff = diff(abs(Sacc(3,:))>500);
accelOnset = find(SaccDiff==1);
latency = accelOnset(1) - onset;
accelOffset = find(SaccDiff==-1);
duration =  accelOffset(end) - latency;

    
    Metrics = [latency; duration; peakVel];
end


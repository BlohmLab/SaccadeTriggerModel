function [ KalmanParams ] = Initialize_KalmanParams( input )
%Initialize_KalmanParams_default Sets D,R,Q,Omn for PE, RS, RA Sensory
%Pathways

% Accepts char inputs describing type of param set (eg: 'default', ___ )
% OR numeric input [12x1] with values for {D,R,Q,Omn} for {PE,RS,RA} in that order


%For 'blur' condition, 
% set PE.D = 1.5;
%     PE.R = 2; 

if nargin ==0
    input = 'default';
end

if ischar(input)
    if strcmpi(input, 'default')
        %% KalmanParams
        %Pos
        KalmanParams.PE.D = 1;              % Mult Noise
        KalmanParams.PE.R = 0.25;            % Additive Noise
        KalmanParams.PE.Q = 0.25;            % Expected Variability
        KalmanParams.PE.Omn = 0.1;           % Internal Process Noise
        %Vel
        KalmanParams.RS.D = 1.5;              % Mult noise
        KalmanParams.RS.R = 7.5;             % Add noise
        KalmanParams.RS.Q = 1;              % Expected variability
        KalmanParams.RS.Omn = 0.3;          % Internal Process Noise
        
        %Accel
        KalmanParams.RA.D =1;               % mult noise
        KalmanParams.RA.R = 50;             % add noise
        KalmanParams.RA.Q = 30;             % Expected variability
        KalmanParams.RA.Omn = 10;           % Internal Process noise
        
    else
        fprintf('Char input not recognized \n Expecting: ''default'' \nSee comments for help \n')
    end
elseif isnumeric(input)
    if length(input) == 12
        %% KalmanParams
        %Pos
        KalmanParams.PE.D = input(1);              % Mult Noise
        KalmanParams.PE.R = input(2);            % Additive Noise
        KalmanParams.PE.Q = input(3);            % Expected Variability
        KalmanParams.PE.Omn = input(4);           % Internal Process Noise
        %Vel
        KalmanParams.RS.D = input(5);              % Mult noise
        KalmanParams.RS.R = input(6);             % Add noise
        KalmanParams.RS.Q = input(7);              % Expected variability
        KalmanParams.RS.Omn = input(8);          % Internal Process Noise
        
        %Accel
        KalmanParams.RA.D = input(9);               % mult noise
        KalmanParams.RA.R = input(10);             % add noise
        KalmanParams.RA.Q = input(11);             % Expected variability
        KalmanParams.RA.Omn = input(12);           % Internal Process noise
    end
else
    fprintf('Unknown input (not char flag or numeric param vector \n See comments for help \n')
end


end


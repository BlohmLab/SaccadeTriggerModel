function [ MotorParams ] = Initialize_MotorParams( input )
%Initialize_MotorParams Sets Params for Sacc and Purs motor systems
%% MotorParams

if nargin==0
    input = 'default';
end

if ischar(input)
    if strcmpi(input, 'default')
        MotorParams.saccGain = 0.9;
        MotorParams.pursGainStd = 0.05;
        MotorParams.pursGainMean = 0.93;
    else
        fprintf('Unrecognized char input. \n Expecting: ''default'' \n See comments for help \n')
    end
elseif isnumeric(input)
    if length(input) == 3
        MotorParams.saccGain = input(1);
        MotorParams.pursGainMean = input(2);
        MotorParams.pursGainStd = input(3);
    else
        fprintf('Numeric array size does not match number of parameters \n Expecting numeric array with numel=3 \nSee comments for help \n')
    end
else
    fprintf('Unrecognized input (neither char array nor numeric) \n See comments for help \n')
end

end


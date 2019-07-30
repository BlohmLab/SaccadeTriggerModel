function [ Params ] = Initialize_DefaultTriggerModel(  )
%Initialize_DefaultTriggerModel Initializes KalmanParams, DecisionParams, MotorParams based on default settings

KalmanParams = Initialize_KalmanParams;
DecisionParams = Initialize_DecisionParams;
MotorParams = Initialize_MotorParams;

Params = struct('KalmanParams', KalmanParams, 'DecisionParams', DecisionParams, ...
                        'MotorParams', MotorParams);
end


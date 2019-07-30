function [ conditionVector ] = Find_conditionVector( indexVector, TrialParams )
%Find_conditionVector gives specific conditions (SR1; PS; VS) for given index (useful to make figTitles / sanity checking while looping through conditions)
%   Detailed explanation goes here

%% Single Step Ramp
if strcmpi(TrialParams.flag_trialType, 'singleStepRamp')
    if numel(indexVector) ~= 2
        fprintf('Error, expecting conditionVect size(2x1) [PS;VS] \n')
        return
    end
    
    PS = TrialParams.flag_trialDetails{1}(indexVector(1));
    VS = TrialParams.flag_trialDetails{2}(indexVector(2));
    
    conditionVector = [PS;VS];
    
    
%% Double Step Ramp
elseif strcmpi(TrialParams.flag_trialType, 'doubleStepRamp')
    if numel(indexVector) ~= 3
        fprintf('Error, expecting conditionVect size(2x1) [SR1; PS;VS] \n')
        return
    end
    
    SR1 = TrialParams.flag_trialDetails{1}(1,indexVector(1));   %SR1 is displacement of 1st StepRamp (Rashbass)
    VS = TrialParams.flag_trialDetails{3}(indexVector(3));
    
    
    if strcmpi(TrialParams.flag_trialDetails{4}, 'deBrouwer')
        if VS < -10
            PS = TrialParams.flag_trialDetails{2}(1,indexVector(2));
        elseif VS>10
            PS = TrialParams.flag_trialDetails{2}(3,indexVector(2));
        else
            PS = TrialParams.flag_trialDetails{2}(2,indexVector(2));
        end
    else
        PS = TrialParams.flag_trialDetails{2}(indexVector(2));
    end
    
    conditionVector = [SR1; PS; VS];
    
end


end


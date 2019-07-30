function [ indexVector ] = Find_indexVector( conditionVector, TrialParams )
%Find_indexVector finds appropriate indices for specified condition
%   given desired condition [PS, VS, SR1]
%   outputs indexVector: [PSi, VSi, SR1i] corresponding to those conditions

% If you know what type of step-ramp etc you want to plot/analyze
% This function will tell you what indices to find that data in

trialDetails = TrialParams.trialDetails;
trialType = TrialParams.trialType;

%% For Single Step Ramp
if strcmpi(trialType, 'singleStepRamp')
    % trialDetails = {PSrange, VSrange, char tag}
    % indexVector = [PSi; VSi]    
    
    if numel(conditionVector) ~= 2
        fprintf('Error, expecting conditionVect size(2x1) [PS;VS] \n')
        return
    end
    
    VS = conditionVector(2);
    VSi = find( abs(trialDetails{2} - VS)<0.01); 
    
    if strcmpi(trialDetails{3}, 'txt')
        txt = conditionVector(1);
        PS = -txt.*VS;
        PSi = find(  abs(-VS.*trialDetails{1} - PS)<0.01);  %Since conditionVector(1) is a PS, convert TxtRange to PSrange then find index corresponding to PS

    else
        PS = conditionVector(1);
        PSi = find(  abs(trialDetails{1} - PS)<0.01);
    end
    

    % In case indices not found
    if isempty(VSi)
        VSrangeStr = sprintf('%d, ', trialDetails{2});
        VSrangeStr = VSrangeStr(1:end-2);
        errorMessage = sprintf(['Error, VS value not found. Values in VSrange: ', VSrangeStr])
        return
    end
    
    if isempty(PSi)
        if strcmpi(trialDetails{3},'txt')
            fprintf('Current trialDetails specify txtRange. Still expecting a PS input \n')
            PSrangeStr = sprintf('%d, ', -VS*trialDetails{1});
            PSrangeStr = PSrangeStr(1:end-2);
            errorMessage = sprintf(['Error, PS value not found. Values in converted PSrange:', PSrangeStr])
            return
        else
            PSrangeStr = sprintf('%d, ', trialDetails{1});
            PSrangeStr = PSrangeStr(1:end-2);
            errorMessage = sprintf(['Error, PS value not found. Values in PSrange:', PSrangeStr])
            return
        end
    end
    
    indexVector = [PSi; VSi];

%% For Double Step Ramp
elseif strcmpi(trialType, 'doubleStepRamp')
    
    if numel(conditionVector) ~= 3
        fprintf('Error, expecting conditionVect size(3x1), [SR1(1);PS;VS] \n')
        return
    end
    
    SR1 = conditionVector(1);
    PS = conditionVector(2);
    VS = conditionVector(3);
    
    SR1i = find( trialDetails{1}(1,:) == SR1);
    VSi = find( abs(trialDetails{3}-VS)<0.01);
    
    %trialDetails{2} = PSrange = [PSrangeNegVS; PSrangeMidVS; PSrangePosVS]
    if strcmpi(trialDetails{4}, 'deBrouwer')
        if VS < -10
            PSi = find( abs(trialDetails{2}(1,:)-PS)<0.01);
        elseif VS>10
            PSi = find( abs(trialDetails{2}(3,:)-PS)<0.01);
        else
            PSi = find( abs(trialDetails{2}(2,:)-PS)<0.01);
        end
    else
        PSi = find( abs(trialDetails{2}(:)-PS)<0.01);
    end
    
    % In case indices not found
    if isempty(SR1i)
        SR1rangeStr = sprintf('%d, ', trialDetails{1});
        SR1rangeStr = SR1rangeStr(1:end-2);
        errorMessage = sprintf(['Error, SR1(1) value not found. Values in SR1range: ', SR1rangeStr])
        return
    end
    
    if isempty(VSi)
        VSrangeStr = sprintf('%d, ', trialDetails{2});
        VSrangeStr = VSrangeStr(1:end-2);
        errorMessage = sprintf(['Error, VS value not found. Values in VSrange: ', VSrangeStr])
        return
    end
    
    if isempty(PSi)
        if VS<-10
            PSrangeStr = sprintf('%d, ', trialDetails{2}(1,:));
        elseif VS>10
            PSrangeStr = sprintf('%d, ', trialDetails{2}(3,:));
        else
            PSrangeStr = sprintf('%d, ', trialDetails{2}(2,:));
        end
        PSrangeStr = PSrangeStr(1:end-2);
        errorMessage = sprintf(['Error, PS value not found. Values in PSrange: ', PSrangeStr])
        return
    end
    
    indexVector = [SR1i; PSi; VSi];
    
%% If trialType unrecognized 
else
    fprintf('Unrecognized trialType. Possible trialTypes: ''singleStepRamp'', ''doubleStepRamp'' \n')

end


function [ DecisionParams ] = Initialize_DecisionParams( input )
%Initialize_DecisionParams_default
%   Initializes RSdelT, RAdelT, peThresh, decisionTau, saccThresh
% 
% Input can be character 'flag' that specifies some set of conditions in
% words
% OR input can be [5x1] numeric vector of params. 
% order: RSdelT, RAdelT, peThresh, decisionTau, saccThresh
% (essentially in order of occurrence in loop
% also note for nomenclature: numeric variables use casing: lowerThenUpperCase
%                             exception: RSdelT, RAdelT since delT is
%                             awkward
%       for structs: UpperCaseTheWholeWay

if nargin ==0
    input='default';
end

if ischar(input)
    if strcmpi(input, 'default')
        
        DecisionParams.RSdelT = 0.125;
        DecisionParams.RAdelT = 0.07;
        DecisionParams.peThresh = 0;
        DecisionParams.decisionTau = 25;
        DecisionParams.saccThresh = 4.0;
        DecisionParams.decisionNoise = 0.0;

    else
        fprintf('Error, unrecognized char input \n Expected inputs: ''default'' \n See comments for help \n');
    end
elseif isnumeric(input)
    if length(input) == 6
        DecisionParams.RSdelT = input(1);
        DecisionParams.RAdelT = input(2);
        DecisionParams.peThresh = input(3);
        DecisionParams.decisionTau = input(4);
        DecisionParams.saccThresh = input(5);
        DecisionParams.decisionNoise = input(6);
    else
        fprintf('Error, expecting numeric input size 5x1 \n See comments for help \n')
    end
else
    fprintf('Unknown input (not char flag or numeric param vector \n See comments for help \n')
end

end


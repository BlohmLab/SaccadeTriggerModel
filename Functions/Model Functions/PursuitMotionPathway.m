function [ Evect ] = PursuitMotionPathway( Evect, RS, gain )
%PursuitMotionPathway 
% J Coutinho (2017)
    % Produces and sustains SPEM for given instantaneous RS
    
    if nargin < 3
        gain =1;
    end
    
    
% Motor Params
dT = 0.001;
a=0.013+1.6*35;
b=0.013*1.6*35 + 35^2;
c = 35^2*0.013;
Hmat= [1 dT 0 0;0 1 dT 0;0 0 1 dT;-c -b -a 0];
Hin = [0;0; 0; 7*0.9*35^2];

Evect = Hmat*Evect + Hin*(RS.*gain);


end


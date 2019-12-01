function BrAdj = AdjustLocCntrst( bright, thrsh, alp )
% INPUT: brigth: 1 channel, double 0~1, already GammaInv.
% alp: parameter

%% For debug: 
debug = 0;
if  debug
    bright = linspace(0, 1, 1000);
    thrsh = 0.1;
    alp = 0.;
end

 
BrAdj = bright; 

rngLow  = thrsh;
rngHigh = 1 - rngLow;

%%  exponent
% BrAdj(BrAdj>=thrsh) =  thrsh + rngHigh * ( (BrAdj(BrAdj>=thrsh) - thrsh)/rngHigh ).^ alp ; 
% BrAdj(BrAdj<thrsh)  =  thrsh - rngLow  * ( (thrsh - BrAdj(BrAdj<thrsh)) /rngLow   ).^ alp ; 

%% Sin
% BrAdj(BrAdj>=thrsh) =  BrAdj(BrAdj>=thrsh) + alp .* sin( (BrAdj(BrAdj>=thrsh) - thrsh)/rngHigh * pi ); 
% BrAdj(BrAdj<thrsh)  =  BrAdj(BrAdj<thrsh)  + alp .* sin( (BrAdj(BrAdj <thrsh) - thrsh)/rngLow  * pi ); 


%% Spline
%define a spline function [0,1] --> [0,1]
% x = [0, alp, 1];      % alp 0~ 1 
% y = [0, 1-alp, 1]; 
% xi = 0:0.01:1; 
% yi = interp1(x,y,xi, 'spline'); 
% figure; hold on;
% plot(x,y,'bo',xi,yi, 'r-');

%% Bezier
%alp = 0.5: linear;   alp > 0.5: reduce contrast;  alp < 0.5: increase contrast (typical, 0.2)
[x,y] = Bezier(0:0.001:1, alp);

for i = 1: length(BrAdj(:))
    xx = BrAdj(i) - thrsh;
    if xx >= 0 
        xx = xx/rngHigh;
        [C,idx] = min(abs(x-xx));
        BrAdj(i) =  thrsh + rngHigh * y(idx);  
    else 
        xx = -xx/rngLow;
        [C,idx] = min(abs(x-xx));
        BrAdj(i) =  thrsh - rngLow * y(idx);  
    end
end
% 

if debug
    figure; 
    plot(BrAdj);
end
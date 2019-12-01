%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function xyz = ill2xyz(ill)
%  Conversion from illumination-invariant color space to XYZ.
%  "A Perception-based Color Space for Illumination-invariant Image
%  Processing"
%  Chong, Gortler, and Zickler, SIGGRAPH 2008
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xyz = ill2xyz(ill)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2009 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


B = [0.9465229   0.2946927 -0.1313419; ...
    -0.1179179   0.9929960  0.007371554; ...
     0.09230461 -0.04645794 0.9946464];
 
A = [27.07439  -22.80783  -1.806681; ...
     -5.646736  -7.722125 12.86503; ...
     -4.163133  -4.579428 -4.576049];
 
illVec = reshape(ill, size(ill,1)*size(ill,2), size(ill,3))';

xyzVec = inv(B)*exp(inv(A)*illVec);

xyz = reshape(xyzVec', size(ill,1), size(ill,2), size(ill, 3));


    

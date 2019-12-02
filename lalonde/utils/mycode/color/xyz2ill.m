%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ill = xyz2ill(xyz)
%  Conversion from XYZ color space to the illumination-invariant color space from
%  "A Perception-based Color Space for Illumination-invariant Image Processing"
%  Chong, Gortler, and Zickler, SIGGRAPH 2008
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ill = xyz2ill(xyz)
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
 
xyzVec = reshape(xyz, size(xyz,1)*size(xyz,2), size(xyz,3))';

illVec = A*log(B*xyzVec);

ill = reshape(illVec', size(xyz,1), size(xyz,2), size(xyz, 3));


    

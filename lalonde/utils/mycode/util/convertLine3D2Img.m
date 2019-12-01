%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function fLineImg = convertLine3D2Img(fLine3D, horizonLine, focalLength, cameraHeight, u0)
%   Converts a line in 3-D coordinates to image representation, given camera parameters as input
% 
% Input parameters: 
%  - fLine3D: 3-D (3xN) points
%  - horizonLine: horizon y coordinate (in pixels)
%  - focalLength: estimated focal length (in pixels)
%  - cameraHeight: estimated camera height (in meters)
%  - u0: half image width (in pixels)
% 
% Output parameters: 
%  - fLineImg: line (2xN) in image coordinates (in pixels)
%  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fLineImg = convertLine3D2Img(fLine3D, horizonLine, focalLength, cameraHeight, u0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fLineY = (focalLength .* (cameraHeight-fLine3D(2,:))) ./ fLine3D(3,:) + horizonLine;
fLineX = fLine3D(1,:) .* focalLength ./ fLine3D(3,:) + u0;
fLineImg = [fLineX; fLineY];
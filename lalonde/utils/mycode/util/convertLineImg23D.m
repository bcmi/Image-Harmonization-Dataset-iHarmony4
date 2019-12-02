%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function fLine3D = convertLineImg23D(fLineImg, horizonLine, focalLength, cameraHeight, u0)
%   Converts a line in image coordinates to a 3-D representation, given camera parameters as input
% 
% Input parameters: 
%  - fLineImg: line (2xN) in image coordinates (in pixels)
%  - horizonLine: horizon y coordinate (in pixels)
%  - focalLength: estimated focal length (in pixels)
%  - cameraHeight: estimated camera height (in meters)
%  - u0: half image width (in pixels)
% 
% Output parameters: 
%  - fLine3D: 3-D (3xN) points
%  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fLine3D = convertLineImg23D(fLineImg, horizonLine, focalLength, cameraHeight, u0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fPolyZ = (focalLength .* cameraHeight) ./ (fLineImg(2,:) - horizonLine);
fPolyX = (fLineImg(1,:) - u0) .* fPolyZ ./ focalLength;
fLine3D = [fPolyX; zeros(1, length(fPolyX)); fPolyZ];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [X, Y, Z] = rgb2xyY(R,G,B)
%  Converts an image in RGB format to the xyY format, as described in 
%  http://en.wikipedia.org/wiki/CIE_1931_Color_Space
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xyY = rgb2xyY(rgb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first convert to XYZ
cTrans = makecform('srgb2xyz');
xyz = applycform(rgb, cTrans);

X = xyz(:,:,1);
Y = xyz(:,:,2);
Z = xyz(:,:,3);

% get chromaticities (normalize)
x = X ./ (X+Y+Z);
y = Y ./ (X+Y+Z);

indZero = (X+Y+Z) == 0;
x(indZero) = 0;
y(indZero) = 0;
Y(indZero) = 0;

xyY = cat(3,x,y,Y);

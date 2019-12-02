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
function [x, y, Y] = xyz2xyY(X, Y, Z)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin == 1)
    Z = X(:,:,3);
    Y = X(:,:,2);
    X = X(:,:,1);
end

% get chromaticities (normalize)
x = X ./ (X+Y+Z);
y = Y ./ (X+Y+Z);

indZero = (X+Y+Z) == 0;
x(indZero) = 0;
y(indZero) = 0;
Y(indZero) = 0;

if nargout == 1
    x = cat(3, x, y, Y);
end

% xyY = cat(3,x,y,Y);

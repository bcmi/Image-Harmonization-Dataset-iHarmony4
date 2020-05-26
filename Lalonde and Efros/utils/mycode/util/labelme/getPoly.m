%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function poly = getPoly(polygon)
%   Converts a single polygon from XML to doubles
% 
% Input parameters:
%   - polygon: input polygon (string, from XML)
%
% Output parameters:
%   - poly: same polygon, in doubles
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function poly = getPoly(polygon)

[xPoly,yPoly] = getLMpolygon(polygon);
poly = [xPoly yPoly];
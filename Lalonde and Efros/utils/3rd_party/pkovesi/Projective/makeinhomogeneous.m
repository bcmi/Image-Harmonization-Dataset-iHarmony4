% MAKEINHOMOGENEOUS - Converts homogeneous coords to inhomogeneous coordinates 
%
% Usage:  x = makehomogeneous(hx)
%
% Argument:
%         hx  - an N x npts array of homogeneous coordinates.
%
% Returns:
%         x - an (N-1) x npts array of inhomogeneous coordinates
%
% Warning:  If there are any points at infinity (scale = 0) the coordinates
% of these points are simply returned minus their scale coordinate.
%
% See also: MAKEHOMOGENEOUS, HNORMALISE

% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% April 2010

function x = makeinhomogeneous(hx)
    
    hx = hnormalise(hx);  % Normalise to scale of one
    x = hx(1:end-1,:);    % Extract all but the last row


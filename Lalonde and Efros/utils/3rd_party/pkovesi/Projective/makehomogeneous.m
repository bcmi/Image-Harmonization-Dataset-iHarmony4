% MAKEHOMOGENEOUS - Appends a scale of 1 to array inhomogeneous coordinates 
%
% Usage:  hx = makehomogeneous(x)
%
% Argument:
%         x  - an N x npts array of inhomogeneous coordinates.
%
% Returns:
%         hx - an (N+1) x npts array of homogeneous coordinates with the
%              homogeneous scale set to 1
%
% See also: MAKEINHOMOGENEOUS

% Peter Kovesi  
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/~pk
%
% April 2010

function hx = makehomogeneous(x)
    
    [rows, npts] = size(x);
    hx = ones(rows+1, npts);
    hx(1:rows,:) = x;


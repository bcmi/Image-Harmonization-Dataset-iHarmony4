% INVHT - inverse of a homogeneous transformation matrix
%
% Usage:  Tinv = invht(T)
%
% Argument:   T    - 4x4 homogeneous transformation matrix
% Returns:    Tinv - inverse
%
% See also: TRANS, ROTX, ROTY, ROTZ

% Copyright (c) 2001 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function Tinv = invht(T)
  
  A = T(1:3,1:3);
  
  Tinv = [   A'   -A'*T(1:3,4)
           0 0 0       1      ];
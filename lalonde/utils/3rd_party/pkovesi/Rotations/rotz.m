% ROTZ - Homogeneous transformation for a rotation about the z axis
%
% Usage: T = rotz(theta)
%
% Argument:  theta  - rotation about z axis
% Returns:    T     - 4x4 homogeneous transformation matrix
%
% See also: TRANS, ROTX, ROTY, INVHT

% Copyright (c) 2001 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function T = rotz(theta)

T = [ cos(theta) -sin(theta)  0   0
      sin(theta)  cos(theta)  0   0
          0           0       1   0
          0           0       0   1];


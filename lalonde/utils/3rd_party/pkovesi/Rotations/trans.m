% TRANS - Homogeneous transformation for a translation by x, y, z
%
% Usage: T = trans(x, y, z)
%        T = trans(v)
%
% Arguments:  x,y,z - translations in x,y and z, or alternatively
%             v     - 3-vector defining x, y and z.
% Returns:    T     - 4x4 homogeneous transformation matrix
%
% See also: ROTX, ROTY, ROTZ, INVHT

% Copyright (c) 2001 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function T = trans(x, y, z)

  if nargin == 1   % x is a 3-vector
    y = x(2); z = x(3); x = x(1);
  end
  
  T = [ 1  0  0  x
        0  1  0  y
        0  0  1  z
        0  0  0  1];
  
  
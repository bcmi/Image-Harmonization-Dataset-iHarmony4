% VECTOR2QUATERNION - embeds 3-vector in a quaternion representation
%
% Usage: Q = vector2quaternion(v)
%
% Argument:  v - 3-vector
% Returns:   Q - Quaternion given by [0; v(:)]
%
% See also: NEWQUATERNION, QUATERNIONROTATE, QUATERNIONPRODUCT, QUATERNIONCONJUGATE

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/
    
function Q = vector2quaternion(v)

  if length(v) ~= 3
    error('v must be a 3-vector');
  end

  Q = [0; v(:)];
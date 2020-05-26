% QUATERNIONCONJUGATE - Conjugate of a quaternion
%
% Usage: Qconj = quaternionconjugate(Q)
%
% Argument: Q     - Quaternions in the form  Q = [Qw Qi Qj Qk]
% Returns:  Qconj - Conjugate
%
% See also: NEWQUATERNION, QUATERNIONROTATE, QUATERNIONPRODUCT

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function Qconj = quaternionconjugate(Q)
    
    Qconj = Q(:);
    Qconj(2:4) = -Qconj(2:4);

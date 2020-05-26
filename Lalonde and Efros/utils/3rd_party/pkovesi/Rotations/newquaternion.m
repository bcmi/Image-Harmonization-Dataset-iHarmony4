% NEWQUATERNION  - Construct quaternion 
%
%  Q = newquaternion(theta, axis)
%
% Arguments: theta - angle of rotation
%            axis  - 3-vector defining axis of rotation
% Returns:   Q     - a quaternion in the form [w xi yj zk]
%
% See Also:  QUATERNION2MATRIX, MATRIX2QUATERNION, QUATERNIONROTATE

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function Q = newquaternion(theta, axis)
    
    axis = axis./norm(axis);
    Q = zeros(4,1);    
    Q(1) = cos(theta/2);
    Q(2:4) = sin(theta/2)*axis;
    
    
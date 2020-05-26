% QUATERNIONROTATE - Rotates a 3D vector by a quaternion 
%
% Usage:   vnew = quaternionrotate(Q, v)
%
% Arguments: Q - a quaternion in the form [w xi yj zk]
%            v - a vector to rotate, either an inhomogeneous 3-vector or a
%            homogeneous 4-vector
% Returns:   vnew - rotated vector
%
% See also MATRIX2QUATERNION, QUATERNION2MATRIX, NEWQUATERNION

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% Code forms the equivalent 3x3 rotation matrix from the quaternion and
% applies it to a vector 
%
% Note that Qw^2 + Qi^2 + Qj^2 + Qk^2 = 1
% So the top-left entry of the rotation matrix of
%   Qw^2 + Qi^2 - Qj^2 - Qk^2
% can be rewritten as
%   Qw^2 + Qi^2 + Qj^2 + Qk^2 - 2Qj^2 - 2Qk^2
% = 1 - 2Qj^2 - 2Qk^2
%
% Similar optimization applies to the other diagonal elements

function vnew = quaternionrotate(Q, v)

    % Copy v to vnew to allocate space.  If v is a 4 element homogeneous
    % vector this also sets the homogeneous scale factor of vnew
    vnew = v;  
    
    Qw = Q(1);  Qi = Q(2);  Qj = Q(3);  Qk = Q(4);
    
    t2 =   Qw*Qi;
    t3 =   Qw*Qj;
    t4 =   Qw*Qk;
    t5 =  -Qi*Qi;
    t6 =   Qi*Qj;
    t7 =   Qi*Qk;
    t8 =  -Qj*Qj;
    t9 =   Qj*Qk;
    t10 = -Qk*Qk;
    vnew(1) = 2*( (t8 + t10)*v(1) + (t6 -  t4)*v(2) + (t3 + t7)*v(3) ) + v(1);
    vnew(2) = 2*( (t4 +  t6)*v(1) + (t5 + t10)*v(2) + (t9 - t2)*v(3) ) + v(2);
    vnew(3) = 2*( (t7 -  t3)*v(1) + (t2 +  t9)*v(2) + (t5 + t8)*v(3) ) + v(3);
    
 

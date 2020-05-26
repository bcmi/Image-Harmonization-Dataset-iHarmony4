% INVEULER - inverse of Euler transform
%
% Usage:  [euler1, euler2] = inveuler(T)
%
% Argument:  T - 4x4 Homogeneous transformation matrix or 3x3 rotation matrix
% Returns: euler1 = [phi1, theta1, psi1] - the 1st solution and,
%          euler2 = [phi2, theta2, psi2] - the 2nd solution
%
%  rotz(phi1)*roty(theta1)*rotz(psi1) = T
%
% See also: INVRPY, INVHT, ROTX, ROTY, ROTZ

% Reference: Richard P. Paul  Robot Manipulators: Mathematics, Programming and Control.
% MIT Press 1981. Page 68
%
% Copyright (c) 2001 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function [euler1, euler2] = inveuler(T)

    phi1 = atan2(T(2,3), T(1,3));
    phi2 = phi1 + pi;
    
    theta1 = atan2(cos(phi1)*T(1,3) + sin(phi1)*T(2,3), T(3,3));
    theta2 = atan2(cos(phi2)*T(1,3) + sin(phi2)*T(2,3), T(3,3));
    
    psi1 = atan2(-sin(phi1)*T(1,1) + cos(phi1)*T(2,1), ...
                 -sin(phi1)*T(1,2) + cos(phi1)*T(2,2));
    psi2 = atan2(-sin(phi2)*T(1,1) + cos(phi2)*T(2,1), ...
                 -sin(phi2)*T(1,2) + cos(phi2)*T(2,2));
    
    euler1 = [phi1, theta1, psi1];
    euler2 = [phi2, theta2, psi2];
    
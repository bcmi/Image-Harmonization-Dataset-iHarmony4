% NEWANGLEAXIS - Constructs angle-axis descriptor
%
% Usage: t = newangleaxis(theta, axis)
%
% Arguments: theta - angle of rotation
%            axis  - 3-vector defining axis of rotation
% Returns:   t     - 3-vector giving rotation axis with magnitude equal to the
%                    rotation angle in radians.
%
% See also: MATRIX2ANGLEAXIS, ANGLEAXISROTATE, ANGLEAXIS2MATRIX
%           NORMALISEANGLEAXIS

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function t = newangleaxis(theta, axis)
    
    if length(axis) ~= 3
        error('axis must be a 3 vector');
    end
    
    axis = axis/norm(axis);  % Make unit length
    
    % Normalise theta to lie in the range -pi to pi to ensure one-to-one mapping
    % between angle-axis descriptor and resulting rotation.  Note that -ve
    % rotations are achieved by reversing the direction of the axis.
    
    if abs(theta) > pi
        theta = theta*(1 - (2*pi)/abs(theta));
    end
    
    t = theta*axis;
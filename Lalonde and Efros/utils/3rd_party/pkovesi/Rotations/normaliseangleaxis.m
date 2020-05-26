% NORMALISEANGLEAXIS - normalises angle-axis descriptor
%
% Function normalises theta so that it has maximum magnitude of pi to ensure one-to-one
% mapping between angle-axis descriptor and resulting rotation
%
% Usage: t2 = normaliseangleaxis(t)
%
% Argument:   t  - 3-vector giving rotation axis with magnitude equal to the
%                  rotation angle in radians.
% Returns:    t2 - Normalised angle-axis descriptor
%
% Note this function only works for |t| up to a magnitude of 2pi
%
% See also: MATRIX2ANGLEAXIS, NEWANGLEAXIS, ANGLEAXIS2MATRIX, ANGLEAXIS2MATRIX2,
%           ANGLEAXISROTATE

% Copyright (c) 2008 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function t2 = normaliseangleaxis(t)
    
    if length(t) ~= 3
        error('axis must be a 3 vector');
    end
    
    if norm(t) > pi
        t2 = t*(1 - (2*pi)/norm(t));
    else
        t2 = t;
    end
    

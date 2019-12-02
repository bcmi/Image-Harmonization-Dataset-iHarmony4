% ANGLEAXISROTATE - uses angle axis descriptor to rotate vectors
%
% Usage: v2 = angleaxisrotate(t, v)
%
% Arguments:  t  - 3-vector giving rotation axis with magnitude equal to the
%                  rotation angle in radians.
%             v  - 4xn matrix of homogeneous 4-vectors to be rotated or
%                  3xn matrix of inhomogeneous 3-vectors to be rotated
% Returns:    v2 - The rotated vectors. 
%
% See also: MATRIX2ANGLEAXIS, NEWANGLEAXIS, ANGLEAXIS2MATRIX, ANGLEAXIS2MATRIX2,
%           NORMALISEANGLEAXIS

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

function v2 = angleaxisrotate(t, v)
    
    [ndim,npts] = size(v);

    T = angleaxis2matrix(t);

    if ndim == 3
      v2 = T(1:3,1:3)*v;

    elseif ndim == 4
      v2 = T*v;

    else
      error('v must be 4xN or 3xN');
    end



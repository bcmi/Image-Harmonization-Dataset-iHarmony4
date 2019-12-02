% ANGLEAXIS2MATRIX - converts angle-axis descriptor to 4x4 homogeneous
% transformation  matrix
%
% Usage:     T = amgleaxis2matrix(t)
%
% Argument:  t - 3-vector giving rotation axis with magnitude equal to the
%                rotation angle in radians.
% Returns:   T - 4x4 Homogeneous transformation matrix
%
% See also: MATRIX2ANGLEAXIS, ANGLEAXISROTATE, NEWANGLEAXIS, NORMALISEANGLEAXIS

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

function T = angleaxis2matrix(t)

    theta = sqrt(t(:)'*t(:));   % = norm(t), but faster
    if theta < eps    % If the rotation is very small...
        T = [ 1   -t(3) t(2) 0
              t(3) 1   -t(1) 0
             -t(2) t(1) 1    0
              0    0    0    1];
        
        return
    end
    
    % Otherwise set up standard matrix, first setting up some convenience
    % variables
    t = t/theta;  x = t(1); y = t(2); z = t(3);
    
    c = cos(theta); s = sin(theta); C = 1-c;
    xs = x*s;   ys = y*s;   zs = z*s;
    xC = x*C;   yC = y*C;   zC = z*C;
    xyC = x*yC; yzC = y*zC; zxC = z*xC;

    T = [ x*xC+c   xyC-zs   zxC+ys  0
          xyC+zs   y*yC+c   yzC-xs  0
          zxC-ys   yzC+xs   z*zC+c  0
            0         0       0     1];
    
    

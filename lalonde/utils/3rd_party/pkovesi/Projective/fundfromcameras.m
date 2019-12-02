% FUNDFROMCAMERAS - Fundamental matrix from camera matrices
%
% Usage: F = fundfromcameras(P1, P2)
%
% Arguments:  P1, P2 - Two 3x4 camera matrices
% Returns:    F      - Fundamental matrix relating the two camera views
%
% See also: FUNDMATRIX, AFFINEFUNDMATRIX

% Reference: Hartley and Zisserman p244

% Copyright (c) 2009 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
% The Software is provided "as is", without warranty of any kind.

function F = fundfromcameras(P1, P2)

  if ~all(size(P1) == [3 4]) | ~all(size(P2) == [3 4]) 
    error('Camera matrices must be 3x4');
  end

  C1 = null(P1);  % Camera centre 1 is the null space of P1
  e2 = P2*C1;     % epipole in camera 2

  e2x = [  0   -e2(3) e2(2)    % Skew symmetric matrix from e2
         e2(3)    0  -e2(1)
        -e2(2)  e2(1)   0  ];

  F = e2x*P2*pinv(P1);
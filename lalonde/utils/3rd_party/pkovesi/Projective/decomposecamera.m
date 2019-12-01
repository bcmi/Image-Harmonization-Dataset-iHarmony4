% DECOMPOSECAMERA  Decomposition of a camera projection matrix
%
% Usage:  [K, R, C, pp, pv] = decomposecamera(P);
%
%    P is decomposed into the form P = K*[R -R*C]
%
% Argument:  P - 3 x 4 camera projection matrix
% Returns:   
%            K - Calibration matrix of the form
%                  |  ax   s   x0  |
%                  |   0   ay  y0  |
%                  |   0   0    1  |
%
%                Where: 
%                ax = f/pixel_width and ay = f/pixel_height,
%                x0 and y0 define the principal point in pixels,
%                s is the camera skew.
%            R - 3 x 3 rotation matrix defining the orientation of the camera
%                in world coordinates. Columns of R define the directions of
%                the camera X, Y and Z axes in world coordinates.
%            C - Camera centre position in world coordinates.
%           pp - Image principal point.
%           pv - Principal vector  from the camera centre C through pp
%                pointing out from the camera.  This may not be the same as  
%                R(:,3) if the principal point is not at the centre of the
%                image, but it should be similar. 
%
% See also: RQ3

% Reference: Hartley and Zisserman 2nd Ed. pp 155-164

% Copyright (c) 2010 Peter Kovesi
% Centre for Exploration Targeting
% School of Earth and Environment
% The University of Western Australia
% peter.kovesi at uwa edu au
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% October 2010

function [K, R, C, pp, pv] = decomposecamera(P)
    
    % Projection matrix from Hartley and Zisserman p 163 used for testing
    if ~exist('P','var')
        P = [ 3.53553e+2  3.39645e+2  2.77744e+2 -1.44946e+6
             -1.03528e+2  2.33212e+1  4.59607e+2 -6.32525e+5
              7.07107e-1 -3.53553e-1  6.12372e-1 -9.18559e+2];
    end
    
    % Convenience variables for the columns of P
    p1 = P(:,1);
    p2 = P(:,2);
    p3 = P(:,3);
    p4 = P(:,4);    

    M = [p1 p2 p3];
    m3 = M(3,:)';
    
    % Camera centre, analytic solution
    X =  det([p2 p3 p4]);
    Y = -det([p1 p3 p4]);
    Z =  det([p1 p2 p4]);
    T = -det([p1 p2 p3]);    
    
    C = [X;Y;Z;T];  
    C = C/C(4);   
    C = C(1:3);     % Make inhomogeneous
    
    % C = null(P,'r'); % numerical way of computing C
    
    % Principal point
    pp = M*m3;
    pp = pp/pp(3); 
    pp = pp(1:2);   % Make inhomogeneous
    
    % Principal ray pointing out of camera
    pv = det(M)*m3;
    pv = pv/norm(pv);
    
    % Perform RQ decomposition of M matrix. Note that rq3 returns K with +ve
    % diagonal elements, as required for the calibration marix.
    [K R] = rq3(M);
    
    % Check that R is right handed, if not give warning
    if dot(cross(R(:,1), R(:,2)), R(:,3)) < 0
        warning('Note that rotation matrix is left handed');
    end

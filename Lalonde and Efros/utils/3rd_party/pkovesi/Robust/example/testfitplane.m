% TESTFITPLANE - demonstrates RANSAC plane fitting
%
% Usage: testfitplane(outliers, sigma, t, feedback)
%
% Arguments:
%               outliers - Fraction specifying how many points are to be
%                          outliers.
%               sigma    - Standard deviation of inlying points from the
%                          true plane.
%               t        - Distance threshold to be used by the RANSAC
%                          algorithm for deciding whether a point is an
%                          inlier. 
%               feedback - Optional flag 0 or 1 to turn on RANSAC feedback
%                          information.
%
%  Try using:  testfitplane(0.3, 0.05, 0.05)
%
% See also: RANSACFITPLANE, FITPLANE

% Copyright (c) 2003-2005 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
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

% June 2003

function testfitplane(outliers, sigma, t, feedback)

    if nargin == 3
	feedback = 0;
    end
    
    % Hard wire some constants - vary these as you wish
    
    npts = 100;  % Number of 3D data points	
    
    % Define a plane  ax + by + cz + d = 0
    a = 10; b = -3; c = 5; d = 1;
    
    B = [a b c d]';
    B = B/norm(B);
    
    outsigma = 30*sigma;  % outlying points have a distribution that is
                          % 30 times as spread as the inlying points
    
    vpts = round((1-outliers)*npts);  % No of valid points
    opts = npts - vpts;               % No of outlying points
    
    % Generate npts points in the plane
    X = rand(1,npts);
    Y = rand(1,npts);
    Z = (-a*X -b*Y -d)/c;
    
    XYZ =  [X
	    Y
	    Z];
    
    % Add uniform noise of +/-sigma
    XYZ = XYZ + (2*rand(size(XYZ))-1)*sigma;
    
    % Generate opts random outliers
    
    n = length(XYZ);
    ind = randperm(n);  % get a random set of point indices
    ind = ind(1:opts);  % ... of length opts
    
    % Add uniform noise of outsigma to the points chosen to be outliers.
%    XYZ(:,ind) = XYZ(:,ind)  + (2*rand(3,opts)-1)*outsigma;
    
    XYZ(:,ind) = XYZ(:,ind)  +   sign(rand(3,opts)-.5).*(rand(3,opts)+1)*outsigma;    
    
    

    % Display the cloud of points
    figure(1), clf, plot3(XYZ(1,:),XYZ(2,:),XYZ(3,:), 'r*');
    
    % Perform RANSAC fitting of the plane
    [Bfitted, P, inliers] = ransacfitplane(XYZ, t, feedback);

    fprintf('Original plane coefficients: ');
    fprintf('%8.3f ',B);
    fprintf('\nFitted plane coefficients:   ');
    fprintf('%8.3f ',Bfitted);    
    fprintf('\n');
    
    % Display the triangular patch formed by the 3 points that gave the
    % plane of maximum consensus
    patch(P(1,:), P(2,:), P(3,:), 'g')
    
    box('on'), grid('on'), rotate3d('on')
    
    fprintf('\nRotate image so that planar patch is seen edge on\n');
    fprintf('If the fit has been successful the inlying points should\n');
    fprintf('form a line\n\n');    
    

    
    

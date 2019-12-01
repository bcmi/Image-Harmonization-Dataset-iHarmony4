% TESTFITLINE - demonstrates RANSAC line fitting
%
% Usage: testfitline(outliers, sigma, t, feedback)
%
% Arguments:
%               outliers - Fraction specifying how many points are to be
%                          outliers.
%               sigma    - Standard deviation of inlying points from the
%                          true line.
%               t        - Distance threshold to be used by the RANSAC
%                          algorithm for deciding whether a point is an
%                          inlier. 
%               feedback - Optional flag 0 or 1 to turn on RANSAC feedback
%                          information.
%
%  Try using:  testfitline(0.3, 0.05, 0.05)
%
% See also: RANSACFITPLANE, FITPLANE

% Copyright (c) 2003-2006 Peter Kovesi and Felix Duvallet (CMU)
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

% August 2006  testfitline created from testfitplane
%              author: Felix Duvallet

function testfitline(outliers, sigma, t, feedback)

    close all;

    if nargin == 3
        feedback = 0;
    end
    
    % Hard wire some constants - vary these as you wish
    
    npts = 100;  % Number of 3D data points	
    
    % Define a line:
    %    Y = m*X
    %    Z = n*X + Y + b
    % This definition needs fixing, but it works for now
    
    m = 6;
    n = -3;
    b = -4;
    
    outsigma = 30*sigma;  % outlying points have a distribution that is
                          % 30 times as spread as the inlying points
    
    vpts = round((1-outliers)*npts);  % No of valid points
    opts = npts - vpts;               % No of outlying points
    
    % Generate npts points in the line
    X = rand(1,npts);
    
    Y = m*X;
    Z = n*X + Y + b;
    Z = zeros(size(Y));
    
    
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
    XYZ(:,ind) = XYZ(:,ind)  +   sign(rand(3,opts)-.5).*(rand(3,opts)+1)*outsigma;    

    
    % Perform RANSAC fitting of the line
    [V, P, inliers] = ransacfitline(XYZ, t, feedback);
    
    if(feedback)
        disp(['Number of Inliers: ' num2str(length(inliers)) ]);
    end

    % We want to plot the inlier points blue, with the outlier points in
    % red.  In order to do that, we must find the outliers.
    % Use setxor on all the points, and the inliers to find outliers
    %  (plotting all the points in red and then plotting over them in blue
    %  does not work well)
    oulier_points = setxor(transpose(XYZ), transpose(XYZ(:, inliers)), 'rows');
    oulier_points = oulier_points';
    
    % Display the cloud of outlier points
    figure(1); clf
    hold on;
    plot3(oulier_points(1,:),oulier_points(2,:),oulier_points(3,:), 'r*');

    % Plot the inliers as blue points
    plot3(XYZ(1,inliers), XYZ(2, inliers), XYZ(3, inliers), 'b*');

    % Display the line formed by the 2 points that gave the
    % line of maximum consensus as a green line
    line(P(1,:), P(2,:), P(3,:), 'Color', 'green', 'LineWidth', 4);
    
    %Display the line formed by the covariance fitting in magenta
    line(V(1,:), V(2, :), V(3,:), 'Color', 'magenta', 'LineWidth', 5);
    
    box('on'), grid('on'), rotate3d('on')
    
    

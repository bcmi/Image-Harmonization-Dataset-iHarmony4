% RANSACFITPLANE - fits plane to 3D array of points using RANSAC
%
% Usage  [B, P, inliers] = ransacfitplane(XYZ, t, feedback)
%
% This function uses the RANSAC algorithm to robustly fit a plane
% to a set of 3D data points.
%
% Arguments:
%          XYZ - 3xNpts array of xyz coordinates to fit plane to.
%          t   - The distance threshold between data point and the plane
%                used to decide whether a point is an inlier or not.
%          feedback - Optional flag 0 or 1 to turn on RANSAC feedback
%                     information.
%
% Returns:
%           B - 4x1 array of plane coefficients in the form
%               b(1)*X + b(2)*Y +b(3)*Z + b(4) = 0
%               The magnitude of B is 1.
%               This plane is obtained by a least squares fit to all the
%               points that were considered to be inliers, hence this
%               plane will be slightly different to that defined by P below.
%           P - The three points in the data set that were found to
%               define a plane having the most number of inliers.
%               The three columns of P defining the three points.
%           inliers - The indices of the points that were considered
%                     inliers to the fitted plane.
%
% See also:  RANSAC, FITPLANE

% Copyright (c) 2003-2008 Peter Kovesi
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

% June 2003 - Original version.
% Feb  2004 - Modified to use separate ransac function
% Aug  2005 - planeptdist modified to fit new ransac specification
% Dec  2008 - Much faster distance calculation in planeptdist (thanks to
%             Alastair Harrison) 


function [B, P, inliers] = ransacfitplane(XYZ, t, feedback)
    
    if nargin == 2
	feedback = 0;
    end
    
    [rows, npts] = size(XYZ);
    
    if rows ~=3
        error('data is not 3D');
    end
    
    if npts < 3
        error('too few points to fit plane');
    end
    
    s = 3;  % Minimum No of points needed to fit a plane.
        
    fittingfn = @defineplane;
    distfn    = @planeptdist;
    degenfn   = @isdegenerate;

    [P, inliers] = ransac(XYZ, fittingfn, distfn, degenfn, s, t, feedback);
    
    % Perform least squares fit to the inlying points
    B = fitplane(XYZ(:,inliers));
    
%------------------------------------------------------------------------
% Function to define a plane given 3 data points as required by
% RANSAC. In our case we use the 3 points directly to define the plane.

function P = defineplane(X);
    P = X;
    
%------------------------------------------------------------------------
% Function to calculate distances between a plane and a an array of points.
% The plane is defined by a 3x3 matrix, P.  The three columns of P defining
% three points that are within the plane.

function [inliers, P] = planeptdist(P, X, t)
    
    n = cross(P(:,2)-P(:,1), P(:,3)-P(:,1)); % Plane normal.
    n = n/norm(n);                           % Make it a unit vector.
    
    npts = length(X);
    d = zeros(npts,1);   % d will be an array of distance values.

    % The following loop builds up the dot product between a vector from P(:,1)
    % to every X(:,i) with the unit plane normal.  This will be the
    % perpendicular distance from the plane for each point
    for i=1:3
	d = d + (X(i,:)'-P(i,1))*n(i); 
    end
    
    inliers = find(abs(d) < t);
    
    
%------------------------------------------------------------------------
% Function to determine whether a set of 3 points are in a degenerate
% configuration for fitting a plane as required by RANSAC.  In this case
% they are degenerate if they are colinear.

function r = isdegenerate(X)
    
    % The three columns of X are the coords of the 3 points.
    r = iscolinear(X(:,1),X(:,2),X(:,3));
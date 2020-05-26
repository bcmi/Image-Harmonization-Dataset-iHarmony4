% SUBPIX3D   Sub-pixel locations in 3D volume
%
% Usage:    [rs, cs, ss] = subpix3d(r, c, s, L);
%
% Arguments:
%      r, c, s - row, col and scale vectors of extrema to pixel precision.
%            L - 3D volumetric corner data, or 2D + scale space data.
%
% Returns:
%   rs, cs, ss - row, col and scale vectors of valid extrema to sub-pixel
%                precision.
%
% Note that the number of sub-pixel extrema returned can be less than the number
% of integer precision extrema supplied.  Any computed sub-pixel location that
% is more than 0.5 pixels from the initial integer location is rejected.  The
% reasoning is that this implies that the extrema should be centred on a
% neighbouring pixel, but this is inconsistent with the assumption that the
% input data represents extrema locations to pixel precision.
%
% The sub-pixel locations are solved by forming a Taylor series representation
% of the scale-space values in the vicinity of each integer location extrema
%
%   L(x) = L + dL/dx' x + 1/2 x' d2L/dx2 x
%
% x represents a position relative to the integer location of the extrema.  This
% gives us a quadratic and we solve for the location where the gradient is zero
% - these are the extrema locations to sub-pixel precision
%
% Reference: Brown and Lowe "Invariant Features from Interest Point Groups"
%            BMVC 2002  pp 253-262  
%
% See also: SUBPIX2D

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
% July 2010

function [rs, cs, ss] = subpix3d(R, C, S, L)
        
    [rows, cols, scales] = size(L);
    x = zeros(3, length(R));  % Buffer for storing sub-pixel locations
    m = 0;                    % Counter for valid extrema
    
    for n = 1:length(R)
        r = R(n);    % Convenience variables
        c = C(n);
        s = S(n);
    
        % If coords are too close to boundary skip
        if   r < 2      || c < 2      || s < 2        ||  ...
             r > rows-1 || c > cols-1 || s > scales-1
            continue
        end
        
        % Compute partial derivatives via finite differences
        
        % 1st derivatives
        dLdr = (L(r+1,c,s) - L(r-1,c,s))/2;
        dLdc = (L(r,c+1,s) - L(r,c-1,s))/2;
        dLds = (L(r,c,s+1) - L(r,c,s-1))/2;    
        
        D = [dLdr; dLdc; dLds]; % Column vector of derivatives
        
        % 2nd Derivatives
        d2Ldr2 = L(r+1,c,s) - 2*L(r,c,s) + L(r-1,c,s);
        d2Ldc2 = L(r,c+1,s) - 2*L(r,c,s) + L(r,c-1,s);
        d2Lds2 = L(r,c,s+1) - 2*L(r,c,s) + L(r,c,s-1);    
        
        d2Ldrdc = (L(r+1,c+1,s) - L(r+1,c-1,s) - L(r-1,c+1,s) + L(r-1,c-1,s))/4;
        d2Ldrds = (L(r+1,c,s+1) - L(r+1,c,s-1) - L(r-1,c,s+1) + L(r-1,c,s-1))/4;
        d2Ldcds = (L(r,c+1,s+1) - L(r,c+1,s-1) - L(r,c-1,s+1) + L(r,c-1,s-1))/4;
        
        % Form Hessian from 2nd derivatives
        H = [d2Ldr2  d2Ldrdc  d2Ldrds
             d2Ldrdc d2Ldc2   d2Ldcds
             d2Ldrds d2Ldcds  d2Lds2 ];
        
        % Solve for location where gradients are zero - these are the extrema
        % locations to sub-pixel precision
        if rcond(H) < eps
            continue;   % Skip to next point            
%            warning('Hessian is singular');
        else
            dx = -H\D;   % dx is location relative to centre pixel

            % Check solution is within 0.5 pixels of centre.  A solution 
            % outside of this implies that the extrema should be centred on a
            % neighbouring pixel, but this is inconsistent with the
            % assumption that the input data represents extrema locations to
            % pixel precision.  Hence these points are rejected
            if all(abs(dx) <= 0.5) 
                m = m + 1;
                x(:,m) = [r;c;s] + dx;
            end
        end
    
    end
    
    % Extract the subpixel row, column and scale values from x noting we just
    % have m valid extrema.
    rs = x(1, 1:m);
    cs = x(2, 1:m);
    ss = x(3, 1:m);    

% SOLVEINTEG
%
% This function is used by INTEGGAUSFILT to solve for the multiple averaging
% filter widths needed to approximate a Gaussian of desired standard deviation.
%
% Usage: [wl, wu, m, sigmaActual] = solveinteg(sigma, n)
%
% Arguments:  sigma - Desired standard deviation of Gaussian. This should not
%                     be less than one.
%                 n - Number of averaging passes that will be used.  I
%                     suggest using a value that is at least 4, use at least
%                     5, perhaps 6 if you will be taking derivatives.
%
% Returns:       wl - Width of smaller averaging filter to use
%                wu - Width of larger averaging filter to use
%                     (Note wu = wl + 2 and wl is always odd)
%                 m - The number of filterings to be done with the smaller
%                     averaging filter. The number of filterings to be done
%                     with the larger filter is n-m
%       sigmaActual - The actual standard deviation of the approximated
%                     Gaussian that is achieved.
%
% Note that the desired standard deviation will not be achieved exactly.  A
% combination of different sized averaging filters are applied to approximate it
% as closely as possible.  If n is 5 the deviation from the desired standard
% deviation will be at most about 0.15 pixels
%
% To acheive a filtering that approximates a Gaussian with the desired
% standard deviation perform:
%  m filterings with an averaging filter of width wl, followed by
%  n-m filterings with an averaging filter of width wu
%
% See also: INTEGGAUSSFILT, INTEGAVERAGE, INTEGRALIMAGE

% Copyright (c) 2009 Peter Kovesi
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

% September 2009

function [wl, wu, m, sigmaActual] = solveinteg(sigma, n)
    
    if sigma < 0.8
        warning('Sigma values below about 0.8 cannot be represented');
    end
    
    wIdeal = sqrt(12*sigma^2/n + 1); % Ideal averaging filter width    
    
    % wl is first odd valued integer less than wIdeal
    wl = floor(wIdeal);
    if ~mod(wl,2)
        wl = wl-1;
    end
   
    % wu is the next odd value > wl
    wu = wl+2;
    
    % Compute m.  Refer to the tech note for derivation of this formula
    mIdeal = (12*sigma^2 - n*wl^2 - 4*n*wl - 3*n)/(-4*wl - 4);
    m = round(mIdeal);
    
    if m > n || m < 0
        error('calculation of m has failed');
    end
    
    % Compute actual sigma that will be achieved
    sigmaActual = sqrt((m*wl^2 + (n-m)*wu^2 - n)/12);
%    fprintf('wl %d  wu %d  m %d actual sigma %.3f\n', wl, wu, m, sigmaActual);
    
    
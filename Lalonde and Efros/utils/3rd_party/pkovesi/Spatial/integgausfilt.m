% INTEGGAUSFILT - Approximate Gaussian filtering using integral filters
%
% This function approximates Gaussian filtering by repeatedly applying
% averaging filters.  The averaging is performed via integral images which
% results in a fixed and very low computational cost that is independent of
% the Gaussian size.
%
% Usage: fim = integgausfilt(im, sigma, nFilt)
%
% Arguments:
%              im - Image to be Gaussian smoothed
%           sigma - Desired standard deviation of Gaussian filter
%           nFilt - The number of average filterings to be used to
%                   approximate the Gaussian.  This should be a minimum of
%                   3, using 4 is better. If the smoothed image is to be
%                   differentiated an additional averaging should be applied
%                   for each derivative.  Eg if a second derivative is to be
%                   taken at least 5 averagings should be applied. If omitted
%                   this parameter defaults to 5.
%
% Note that the desired standard deviation will not be achieved exactly.  A
% combination of different sized averaging filters are applied to approximate it
% as closely as possible.  If nFilt is 5 the deviation from the desired standard
% deviation will be at most about 0.15 pixels
%
% See also: INTEGAVERAGE, SOLVEINTEG, INTEGRALIMAGE

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

function im = integgausfilt(im, sigma, nFilt)
    
    if ~exist('nFilt', 'var')
        nFilt = 5;
    end
    
    % Solve for the combination of averaging filter sizes that will result in
    % the closest approximation of sigma given nFilt.
    [wl, wu, m] = solveinteg(sigma, nFilt);
    radl = (wl-1)/2;
    radu = (wu-1)/2;
    
    % Apply the averaging filters via integral images.
    for i = 1:m
        im = integaverage(im,radl);
    end
    
    for n = 1:(nFilt-m)
        im = integaverage(im,radu);
    end
 


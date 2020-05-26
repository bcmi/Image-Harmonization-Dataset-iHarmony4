% INTEGGAUSSFILT - Approximate Gaussian filtering using integral filters
%
% This function approximates Gaussian filtering by repeatedly applying
% averaging filters.  The averaging is performed via integral images which
% results in a fixed and very low computational cost that is independent of
% the Gaussian size.
%
% Usage: [fim, sigmaActual] = integgaussfilt(im, sigma, nFilt)
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
% Returns:
%             fim - Smoothed image 
%     sigmaActual - Actual standard deviation of approximate Gaussian filter
%                   that was used    
%
% Notes:
% 1. The desired standard deviation will not be achieved exactly.  A combination
% of different sized averaging filters are applied to approximate it as closely
% as possible.  If nFilt is 5 the deviation from the desired standard deviation
% will be at most about 0.15 pixels.
%
% 2. Values of sigma less than about 1.8 cannot be well approximated by
% repeated averagings.  For sigma < 1.8 the smoothing is performed using
% conventional Gaussian convolution.
%
% See also: INTEGAVERAGE, SOLVEINTEG, INTEGRALIMAGE, GAUSSFILT

% Copyright (c) 2009-2010 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% September 2009 - Original version
% April     2010 - Added return of actual standard deviation of effective
%                  filter used.  Use standard convolution for small sigma

function [im, sigmaActual] = integgaussfilt(im, sigma, nFilt)
    
    if ~exist('nFilt', 'var')
        nFilt = 5;
    end
    
    % First check if sigma is too small to be well represented by repeated
    % averagings.  5 averagings with a width 3 filter produces an equivalent
    % sigma of ~1.8 This represents the minimum threshold.  For sigma less
    % than this we use conventional convolution
    if sigma < 1.8
        im = gaussfilt(im, sigma);
        sigmaActual = sigma;
    
    else  % Use repeated averagings via integral images
    
        % Solve for the combination of averaging filter sizes that will result
        % in the closest approximation of sigma given nFilt.
        [wl, wu, m, sigmaActual] = solveinteg(sigma, nFilt);
        radl = (wl-1)/2;
        radu = (wu-1)/2;
        
        % Apply the averaging filters via integral images.
        for i = 1:m
            im = integaverage(im,radl);
%            im = runningaverage(im,radl);
        end
        
        for n = 1:(nFilt-m)
            im = integaverage(im,radu);
%            im = runningaverage(im,radu);
        end
        
    end

    
%-------------------------------------------------------------------    
% GAUSSFILT -  Small wrapper function for convenient Gaussian filtering
%
% Usage:  smim = gaussfilt(im, sigma)
%

function smim = gaussfilt(im, sigma)
 
    sze = ceil(6*sigma);  
    if ~mod(sze,2)    % Ensure filter size is odd
        sze = sze+1;
    end
    sze = max(sze,1); % and make sure it is at least 1
    
    h = fspecial('gaussian', [sze sze], sigma);
    smim = filter2(h, im);

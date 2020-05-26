% AGC Automatic Gain Control for geophysical images
%
% Usage: agcim = agc(im, sigma, p, r)
%
% Arguments:    im - The input image.  NaNs in the image are handled
%                    automatically. 
%            sigma - The standard deviation of the Gaussian filter used to
%                    determine local image mean values and to perform the
%                    summation used to determine the local gain values.
%                    Sigma is specified in pixels, try experimenting with a
%                    wide range of values. 
%                p - The power used to compute the p-norm of the local image
%                    region. The gain is obtained from the p-norm.  If
%                    unspecified its value defaults to 2 and r defaults to 0.5
%                r - Normally r = 1/p (and it defaults to this) but it can
%                    specified separately to achieve specific results.  See
%                    Rajagopalan's papers.
%
% Returns:   agcim - The Automatic Gain Controlled image.
%
% The algorithm is based on Shanti Rajagopalan's papers, referenced below, with
% a couple of differences.
%
% 1) The gain is computed from the difference between the image and its local
% mean.  The aim of this is to avoid any local base-level issues and to allow
% the code to be applied to a wide range of image types, not just magnetic
% gradient data.  The gain is applied to the difference between the image and
% its local mean to obtain the final AGC image.
%
% 2) The computation of the local mean and the summation operations used to
% compute the local gain is performed using Gaussian smoothing.  The aim of this
% is to avoid abrupt changes in gain as the summation window is moved across the
% image.  The effective window size is controlled by the value of sigma used to
% specify the Gaussian filter.
%
% References:
% * Shanti Rajagopalan "The use of 'Automatic Gain Control' to Display Vertical
%   Magnetic Gradient Data". 5th ASEG Conference 1987. pp 166-169
%
% * Shanti Rajagopalan and Peter Milligan. "Image Enhancement of Aeromagnetic Data
%   using Automatic Gain Control". Exploration Geophysics (1995) 25. pp 173-178

% Copyright (c) 2012 Peter Kovesi
% Centre for Exploration Targeting
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
% The Software is provided "as is", without warranty of any kind.

% April 2012 - Original version

function agcim = agc(im, sigma, p, r)
    
    % Default values for p and r
    if ~exist('p', 'var'), p = 2;   end
    if exist('p','var') & ~exist('r', 'var')
        r = 1/p;
    elseif ~exist('r', 'var')
        r = 0.5; 
    end

    % Make provision for the image containing NaNs
    mask = ~isnan(im);
    if any(mask)
        im = fillnan(im);
    end
    
    % Get local mean by smoothing the image with a Gaussian filter
    h = fspecial('gaussian', 6*sigma, sigma);
    localMean = filter2(h, im);
    
    % Subtract image from local mean, raise to power 'p' then apply Gaussian
    % smoothing filter to obtain a local weighted sum. Finally raise the result
    % to power 'r' to obtain the 'gain'.  Typically p = 2 and r = 0.5 which will
    % make gain equal to the local RMS.  The abs() function is used to allow
    % for arbitrary 'p' and 'r'.
    gain = (filter2(h, abs(im-localMean).^p)).^r;
    
    % Apply inverse gain to the difference between the image and the local
    % mean to obtain the final AGC image. 
    agcim = (im-localMean)./(gain + eps) .* mask; 
    
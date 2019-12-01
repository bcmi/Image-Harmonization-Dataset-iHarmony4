% HISTEQFLOAT Floating point image histogram equalisation
%
% Histogram equalisation for images containing floating point values. The number
% of distinct values in the output image will be the same as the number of
% distinct values in the input image.
%
% Usage:  nim = histeqfloat(im, nbins)
%
% Arguments:    im - Image to be equalised.
%            nbins - Number of bins to use in forming the histogram. Defaults
%                    to 256.
%
% Returns:     nim - Histogram equalised image.
%
% This function differs from classical histogram equalisation functions in that
% the cumulative histogram of the image grey values is treated as forming a set
% of points on the cumulative distribution function.  The key point being that
% it is used as a *function* rather than as a lookup table for mapping input
% grey values to their output values.  Under this approach, for images
% containing floating point values, the number of distinct values in the output
% image will be the same as the number of distinct values in the input image.
% This can result in a significant improvement in output compared to HISTEQ
%
% For integer valued images the number of distinct values in the output image
% must be less than, or equal to, the number of distinct values in the input
% image (typically much less than).
%
% See also: HISTEQ

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

% February 2012

function nim = histeqfloat(im, nbins)
    
    if ~exist('nbins', 'var'), nbins = 256; end
    
    im = normalise(im);  % Adjust image range 0-1
    
    % Compute histogram bin centres and form histogram
    centres = [1/nbins/2 : 1/nbins : 1-1/nbins/2];
    n = hist(im(:), centres);

    n = cumsum(n/sum(n));  % Cumulative sum of normalised histogram
    
    % Use 1D spline interpolation on the cumulative histogram to map image
    % values to their new ones, then reshape the image back to its original
    % size.
    nim = reshape(interp1(centres, n, im(:), 'spline'), size(im));


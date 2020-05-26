% HISTTRUNCATE - Truncates ends of an image histogram.
%
% Function truncates a specified percentage of the lower and
% upper ends of an image histogram.
%
% This operation allows grey levels to be distributed across
% the primary part of the histogram.  This solves the problem
% when one has, say, a few very bright values in the image which
% have the overall effect of darkening the rest of the image after
% rescaling.
%
% Usage: 
%    [newim, sortv] = histtruncate(im, lHistCut, uHistCut)
%    [newim, sortv] = histtruncate(im, lHistCut, uHistCut, sortv)
%
% Arguments:
%    im          -  Image to be processed
%    lHistCut    -  Percentage of the lower end of the histogram
%                   to saturate.
%    uHistCut    -  Percentage of the upper end of the histogram
%                   to saturate.
%    sortv       -  Optional array of sorted image pixel values obtained
%                   from a previous call to histtruncate.  Supplying this
%                   data speeds the operation of histtruncate when one is
%                   repeatedly varying lHistCut and uHistCut.
%

% Copyright (c) 2001-2012 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.cet.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% July     2001 - Original version
% February 2012 - Added handling of NaN values in image

function [newim, sortv] = histtruncate(im, lHistCut, uHistCut, varargin)

    if lHistCut < 0 | lHistCut > 100 | uHistCut < 0 | uHistCut > 100
	error('Histogram truncation values must be between 0 and 100');
    end

    if ndims(im) == 3  % Assume colour image in RGB
	hsv = rgb2hsv(im);     % Convert to HSV 
        % Apply histogram truncation just to intensity component
	if nargin == 3
	    [hsv(:,:,3), sortv] = Ihisttruncate(hsv(:,:,3), lHistCut, uHistCut);
	else
	    [hsv(:,:,3), sortv] = Ihisttruncate(hsv(:,:,3), lHistCut, uHistCut, varargin{1});
	end
	newim = hsv2rgb(hsv);  % Convert back to RGB
    else
	if nargin == 3
	    [newim, sortv] = Ihisttruncate(im, lHistCut, uHistCut);
	else
	    [newim, sortv] = Ihisttruncate(im, lHistCut, uHistCut, varargin{1});
	end
    end
    
    
%-----------------------------------------------------------------------
% Internal function that does the work
%-----------------------------------------------------------------------
    
function [newim, sortv] = Ihisttruncate(im, lHistCut, uHistCut, varargin)    
    
    if ndims(im) > 2
	error('HISTTRUNCATE only defined for grey value images');
    end
    
    im = normalise(im);  % Normalise to 0-1 and cast to double if needed
    
    mask = ~isnan(im);   % Generate a mask of non NaN regions of the image
    m = sum(mask(:));    % Number of non NaN elements.
    
     % Generate a sorted array of pixel values.
    if nargin == 3      
	sortv = sort(im(mask(:)));  
	sortv = [sortv(1); sortv; sortv(m)];
    else
	sortv = varargin{1};
    end
    
    x = 100*(0.5:m - 0.5)./m; % Indices of pixel value order as a percentage
    x = [0 x 100];            % from 0 - 100.
    
    % Interpolate to find grey values at desired percentage levels.
    gv = interp1(x,sortv,[lHistCut, 100 - uHistCut]); 

    newim = imadjust(im,gv,[0 1]);
    newim(~mask) = nan;
    
    

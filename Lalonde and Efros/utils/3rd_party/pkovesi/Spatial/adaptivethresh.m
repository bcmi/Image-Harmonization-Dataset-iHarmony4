% ADAPTIVETHRESH - Wellner's adaptive thresholding
%
% Thresholds an image using a threshold that is varied across the image relative
% to the local mean, or median, at that point in the image.  Works quite well on
% text with shadows
%
% Usage: bw = adaptivethresh(im, fsize, t, filterType, thresholdMode)
%
%        bw = adaptivethresh(im)  (uses default parameter values)
%
% Arguments:  im    - Image to be thresholded.
%
%             fsize - Filter size used to determine the local weighted mean
%                     or local median.  
%                     - If the filterType is 'gaussian' fsize specifies the
%                     standard deviation of Gaussian smoothing to be
%                     applied. 
%                     - If the filterType is 'median' fsize specifies the
%                     size of the window over which the local median is
%                     calculated.  
%
%                     The value for fsize should be large, around one tenth to
%                     one twentieth of the image size.  It defaults to one
%                     twentieth of the maximum image dimension.
%
%             t     - Depending on the value of 'mode' this is the value
%                     expressed as a percentage or fixed amount, relative to
%                     the local average, or median  grey value, below which
%                     the local threshold is set. 
%                     Try values in the range -20 to +20.  
%                     Use +ve values to threshold dark objects against a
%                     white background.   Use -ve values if you are
%                     thresholding white objects on a predominatly 
%                     dark background so that the local threshold is set
%                     above the local mean/median. This parameter defaults to 15.
%
%    filterType     - Optional string specifying smoothing to be used
%                     - 'gaussian' use Gaussian smoothing to obtain local
%                     weighted mean as the  local reference value for setting
%                     the local threshold. This is the default
%                     - 'median' use median filtering to obtain local reference
%                     value for setting the local threshold
%
%    thresholdMode  - Optional string specifying the way the threshold is
%                     defined. 
%                     - 'relative' the value of t represents the percentage,
%                     relative to the local average grey value, below which
%                     the local threshold is set. This is the default.
%                     - 'fixed' the value of t represents the fixed grey level
%                     relative to the local average grey value, below which
%                     the local threshold is set. 
%
%                     Note that in the 'relative' threshold mode the amount the
%                     threshold differs from the local mean/median will vary in
%                     proportion with the local mean/median.  A small difference
%                     from the local mean in the dark regions of the image will
%                     be more significant than the same difference in a bright
%                     portion of the image.  This will match with human
%                     perception.  However this does mean that the results will
%                     depend on the grey value origin and whether the image
%                     is,say, negated.
%
% The implementation differs from Pierre Wellner's original adaptive
% thresholding algorithm in that he calculated the local weighted mean just
% along the row, or pairs of rows, in the image using a recursive filter.  Here
% we use symmetrical 2D Gaussian smoothing to calculate the local mean.  This is
% slower but more general.  This code also offers the option of using median
% filtering as a robust alternative to the mean (outliers will not influence the
% result) and offers the option of using a fixed threshold relative to the
% mean/median.  Despite the potential advantage of median filtering being
% more robust I find the output from using Gaussian filtering more pleasing.
%
% Reference: Pierre Wellner, "Adaptive Thresholding for the DigitalDesk" Rank
% Xerox Technical Report EPC-1993-110  1993

% Copyright (c) 2008 Peter Kovesi
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
%
% August 2008 

function bw = adaptivethresh(im, fsize, t, filterType, thresholdMode)

    % Set up default parameter values as needed
    if nargin < 2
	fsize = fix(length(im)/20);
    end
        
    if nargin < 3
	t = 15;
    end
    
    if nargin < 4
	filterType = 'gaussian';
    end    
    
    if nargin < 5
	thresholdMode = 'relative';
    end
    
    % Apply Gaussian or median smoothing
    if strncmpi(filterType, 'gaussian', 3)
	g = fspecial('gaussian', 6*fsize, fsize);
	fim = filter2(g, im);
    elseif strncmpi(filterType, 'median', 3)
	fim = medfilt2(im, [fsize fsize], 'symmetric');	
    else
	error('Filtertype must be ''gaussian'' or ''median'' ');
    end
    
    % Finally apply the threshold
    if strncmpi(thresholdMode,'relative',3)
	bw = im > fim*(1-t/100);
    elseif  strncmpi(thresholdMode,'fixed',3)
	bw = im > fim-t;
    else
	error('mode must be ''relative'' or ''fixed'' ');
    end
    
% REMAPIM - Remaps image intensity values
%
% Usage:   newim = remapim(im, x, y, rescale)
%                                        \
%                                      optional
% Arguments
%            im  - Image to be transformed.
%            x,y - Coordinates of spline control points that define the
%                  mapping function.  These coordinates are in  the range
%                  0-1 and are typically obtained experimentally via the
%                  function GREYTRANS
%            rescale - An optional flag (0 or 1) indicating whether image
%                      values should  be normalised to the range 0-1. 
%                      This is only provided for speed when called
%                      by GREYTRANS.  By default the input image will
%                      be normalised to the range 0-1.
%
% Image intensity values are remapped to new values via a mapping
% function defined by a series of spline points.  The mapping function is
% defined over the range 0-1, accordingly the input image is normalised
% to the range 0-1.  The output image will also lie in this range.  

% Copyright (c) 2002-2003 Peter Kovesi
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

% April 2002 - original version.
% March 2003 - modified to work with colour images.

function nim = remapim(im, x, y, rescale)

    if nargin < 4
	rescale = 1;
    end
    
    if ndims(im)==3        % Assume we have a colour image
        hsv = rgb2hsv(im);
        % Apply remapping just to the value component
        hsv(:,:,3) =  remap(hsv(:,:,3), x, y, rescale);
        nim = hsv2rgb(hsv);
    else                   % Assume we have a 2D greyscale image
	nim = remap(im, x, y, rescale);
    end


% Internal function that does the work

function nim = remap(im, x, y, rescale)    

    if rescale
	im = normalise(im);
    end
    
    nim = spline(x,y,im);  % Remap image values 

    % clamp image values within bounds 0 - 1
    gt0 = nim > 0;
    nim = nim.*gt0;   % values < 0 become 0
    
    lt1 = nim < 1;
    nim = nim.*lt1 + ~lt1;  % values > 1 become 1


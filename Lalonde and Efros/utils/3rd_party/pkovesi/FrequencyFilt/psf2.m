%  PSF2 - Generates point spread functions for use with deconvolution fns.
%
%  This function can generate a variety function shapes based around the
%  Butterworth filter.  In plan view the filter can be elliptical and at
%  any orientation.  The 'squareness/roundness' of the shape can also be
%  manipulated.
%
%  Usage:  h = psf2(sze, order, ang, lngth, width, sqrness)
%
%   sze   - two element array specifying size of filter [rows cols]
%   order - an even integer specifying the order of the Butterworth filter.
%           This controls the sharpness of the cutoff.
%   ang   - angle of rotation of the filter in radians.
%   lngth - length of the filter in pixels along its major axis.
%   width - width of the filter in pixels along its minor axis.
%   sqrness - even integer specifying 'squareness' of the filter shape
%             a value of 2 gives a circular filter (if lngth == width), higher
%             values make the shape squarer.       
%
% This function is almost identical to psf, it just has a different way of
% specifying the function shape whereby length and width are defined
% explicitly (rather than an average radius), this may be more convenient for
% some applications.

% Copyright (c) 1999-2003 Peter Kovesi
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

% June 1999
% May  2003 - Changed arguments so that psf is specified in terms of a length
%             and width rather than an average radius.

function h = psf2(sze, order, ang, lngth, width, sqrness)

    if mod(sqrness,2) ~=0
	error('squareness parameter must be an even integer');
    end
    
    rows = sze(1);
    cols = sze(2);
    
    [x,y] = meshgrid([1:cols],[1:rows]);

    % The following fiddles the origin to the correct position
    % depending on whether we have and even or odd size
    if mod(cols,2) == 0
      x = x-cols/2-1;
    else
      x = x-(cols+1)/2;
    end
    if mod(rows,2) == 0
      y = y-rows/2-1;
    else
      y = y-(rows+1)/2;
    end
    
    xp = x*cos(ang) - y*sin(ang);   % Rotate axes by specified angle.
    yp = x*sin(ang) + y*cos(ang);
    
    rc = lngth/2;          % Set cutoff radius to half the length 
    yp = yp*lngth/width;   % Adjust y measure to give appropriate relative width.
    
    radius = (xp.^sqrness + yp.^sqrness).^(1/sqrness); % Distort distance metric
						       % by squareness measure.
    h = 1./(1+(radius./rc).^order);  % Butterworth filter 
    h = h./(sum(sum(h)));            % and normalise.
						      

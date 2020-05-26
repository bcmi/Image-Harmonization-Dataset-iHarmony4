%  PSF - Generates point spread functions for use with deconvolution fns.
%
%  This function can generate a variety function shapes based around the
%  Butterworth filter.  In plan view the filter can be elliptical and at
%  any orientation.  The `squareness/roundness' of the shape can also be
%  manipulated.
%
%  Usage:  h = psf(sze, order, ang, eccen, rc, sqrness)
%
%   sze   - two element array specifying size of filter [rows cols]
%   order - an even integer specifying the order of the Butterworth filter.
%           This controls the sharpness of the cutoff.
%   ang   - angle of rotation of the filter in radians
%   eccen - ratio of eccentricity of the filter shape (major/minor axis ratio)
%   rc    - mean radius of the filter in pixels
%   sqrness - even integer specifying `squareness' of the filter shape
%             a value of 2 gives a circular filter (if eccen = 1), higher
%             values make the shape squarer.       

% Copyright (c) 1999 Peter Kovesi
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

function h = psf(sze, order, ang, eccen, rc, sqrness)

    if mod(sqrness,2) ~=0
	error('squareness parameter must be an even integer');
    end
    
    rows = sze(1);
    cols = sze(2);
    
    x = ones(rows,1) * [1:cols]  - (fix(cols/2)+1);
    y = [1:rows]' * ones(1,cols) - (fix(rows/2)+1);
    
    xp = x*cos(ang) - y*sin(ang);   % Rotate axes by specified angle.
    yp = x*sin(ang) + y*cos(ang);
    
    x = sqrt(eccen)*xp;             % Distort x and y according to eccentricity.
    y = yp/sqrt(eccen);
    
    radius = (x.^sqrness + y.^sqrness).^(1/sqrness);  % Distort distance metric
						      % by squareness measure.
    h = 1./(1+(radius./rc).^order);  % Butterworth filter 
    h = h./(sum(sum(h)));            % and normalise.
						      

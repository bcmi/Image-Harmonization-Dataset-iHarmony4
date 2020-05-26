% CANNY - Canny edge detection
%
% Function to perform Canny edge detection. 
%
% Usage: [gradient or] = canny(im, sigma)
%
% Arguments:   im    - image to be procesed
%              sigma - standard deviation of Gaussian smoothing filter
%                      (typically 1)
%
% Returns:     gradient - edge strength image (gradient amplitude)
%              or       - orientation image (in degrees 0-180, positive
%                         anti-clockwise)
%
%
% To obtain a binary edge image one would typically do the following
%  >> [gr or] = canny(im, sigma);   % Choose sigma to taste
%  >> nm = nonmaxsup(gr, or, rad);  % I use a rad value ~ 1.2 to 1.5
%  >> bw = hysthresh(nm, T1, T2);   % Choose T1 and T2 until the result looks ok 
%
% See also:  NONMAXSUP, HYSTHRESH, DERIVATIVE5

% Copyright (c) 1999-2010 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% April   1999  Original version
% January 2003  Error in calculation of d2 corrected
% August  2010  Changed to use derivatives computed using Farid and
%               Simoncelli's filters. Cleaned up

function [gradient, or] = canny(im, sigma)

    assert(ndims(im) == 2, 'Image must be greyscale');
    
    % If needed convert im to double
    if ~strcmp(class(im),'double')
        im = double(im);  
    end

    im = gaussfilt(im, sigma);          % Smooth the image.
    [Ix, Iy] = derivative5(im,'x','y'); % Get derivatives.
    gradient = sqrt(Ix.*Ix + Iy.*Iy);   % Gradient magnitude.
    or = atan2(-Iy, Ix);                % Angles -pi to + pi.
    or(or<0) = or(or<0)+pi;             % Map angles to 0-pi.
    or = or*180/pi;                     % Convert to degrees.
    
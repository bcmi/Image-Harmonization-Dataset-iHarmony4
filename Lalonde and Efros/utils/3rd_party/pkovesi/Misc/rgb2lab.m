% RGB2LAB - RGB to L*a*b* colour space
%
% Usage: Lab = rgb2lab(im)
%
% This function wraps up calls to MAKECFORM and APPLYCFORM in a conveenient
% form.  Note that if the image is of type uint8 this function casts it to
% double and divides by 255 so that the transformed image can have the
% proper negative values for a and b.  (If the image is left as uint8 MATLAB
% will shift the values into the range 0-255)

% Copyright (c) 2009 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

% PK May 2009

function Lab = rgb2lab(im)

%    if ndims(im) ~= 3;
%        error('Image must be a colour image');
%    end
    
    cform = makecform('srgb2lab');
    if strcmp(class(im),'uint8')
        im = double(im)/255;
    end
    Lab = applycform(im, cform);
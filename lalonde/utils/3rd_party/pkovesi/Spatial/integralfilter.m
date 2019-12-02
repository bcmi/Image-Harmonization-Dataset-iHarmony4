% INTEGRALFILTER - performs filtering using an integral image
%
% This function exploits an integral image to perform filtering operations
% (using rectangular filters) on an image in time that only depends on the 
% image size irrespective of the filter size.
%
% Usage: fim = integralfilter(intim, f)
%
% Arguments:  intim - An integral image computed using INTEGRALIMAGE.
%             f     - An n x 5 array defining the filter (see below).
%
% Returns:    fim   - The filtered image.
%
%
% Defining Filters: f is a n x 5 array in the following form
%                   [ r1 c1 r2 c2 v
%                     r1 c1 r2 c2 v
%                     r1 c1 r2 c2 v
%                       .......     ]
%
% Where (r1 c1) and (r2 c2) are the row and column coordinates defining the
% top-left and bottom-right corners of a rectangular region of the filter
% (inclusive) and v is the value to be associated with that region of the
% filter.  The row and column coordinates of the rectangular region are defined
% with respect to the reference point of the filter, typically its centre.
%
% Examples:
%   f = [-3 -3  3  3  1/49]  % Defines a 7x7 averaging filter
%
%   f = [-3 -3  3 -1  -1
%        -3  1  3  3   1];   % Defines a differnce of boxes filter over a 7x7
%                              region where the left 7x3 region has a value
%                              of -1, the right 7x3 region has a value of +1,
%                              and the vertical line of pixels through the
%                              centre have a (default) value of 0.
%
% If you want to check your filter design simply apply it to the integral image
% of an image that is zero everywhere except for one pixel with a value of 1.
% This will give you the impulse response/point spread function of your filter.
%
% Note under MATLAB the execution speed of this filtering code may not be any
% faster than using imfilter (sadly). So in some sense this code is a bit
% academic. However it is interesting that this interpreted code can perform
% filtering at a speed that is comparable to the native code that is exectuted
% via imfilter.  Under Octave there may be useful speed gains.
%
% See also: INTEGRALIMAGE, INTEGAVERAGE, INTFILTTRANSPOSE

% Reference:  Paul Viola and Michael Jones, "Robust Real-Time Face Detection",
% IJCV 57(2). pp 137-154. 2004.

% Copyright (c) 2007 Peter Kovesi
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

% October 2007


function fim = integralfilter(intim, f)

    [rows, cols] = size(intim);
    fim = zeros(rows, cols);
    

    [nfilters, fcols] = size(f);
    if fcols ~= 5
        error('Filters must be specified via an nx5 matrix');
    end

    f(:,1:2) = f(:,1:2)-1;       % Adjust the values of r1 and c1 to save addition
                                 % operations inside the loops below
    
    rmin =  1-min(f(:,1));       % Set loop bounds so that we do not try to
    rmax =  rows - max(f(:,3));  % access values outside the image. 
    cmin =  1-min(f(:,2));
    cmax =  cols - max(f(:,4));
    
    for r = rmin:rmax
        for c = cmin:cmax
            for n = 1:nfilters
            
                fim(r,c) = fim(r,c) + f(n,5)*...
                       (intim(r+f(n,3),c+f(n,4)) - intim(r+f(n,1),c+f(n,4)) ...
                      - intim(r+f(n,3),c+f(n,2)) + intim(r+f(n,1),c+f(n,2)));
            
            end
        end
    end
    
    
    
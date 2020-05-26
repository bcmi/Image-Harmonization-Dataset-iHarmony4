% INTEGAVERAGE - performs averaging filtering  using an integral image
%
% Usage:  avim = integaverage(im,rad)
%
% Arguments:  im      - Image to be filtered
%             rad     - 'Radius' of square region over which averaging is
%                       performed  (rad = 1 implies a 3x3 average) 
% Returns:    avim    - Averaged image
%
% See also:  INTEGRALIMAGE, INTEGRALFILTER, INTFILTTRANSPOSE

% Reference: Paul Viola and Michael Jones, "Robust Real-Time Face Detection",
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

% October   2007 - Original version
% September 2009 - Changed so that input is the image rather than its
%                  integral image

function avim = integaverage(im, rad)
    
    if rad == 0    % Trap case where averaging filter is 1x1 hence radius = 0
        avim = im;
        return;
    end
    
    [rows, cols] = size(im);
    intim = integralimage(im);
    avim = zeros(rows, cols);

    % Fiddle with indices to ensure we calculate the average over a square
    % region that has an odd No of pixels on each side (ie has a centre pixel
    % located over each pixel of interest)
    
    down = rad;   % offset to 'lower' indices
    up = down+1;  % offset to 'upper' indices
    
    for r = 1+up:rows-down
        for c = 1+up:cols-down
            avim(r,c) = intim(r+down,c+down) - intim(r-up,c+down) ...
                       - intim(r+down,c-up) + intim(r-up,c-up);
        end
    end
    
    avim = avim/(down+up)^2;
    
    
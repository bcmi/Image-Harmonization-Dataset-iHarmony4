% INTEGRALIMAGE - computes integral image of an image
%
% Usage:  intim = integralimage(im)
%
% This function computes an integral image such that the value of intim(r,c)
% equals sum(sum(im(1:r, 1:c))
%
% An integral image can be used with the function INTEGRALFILTER to perform
% filtering operations (using rectangular filters) on an image in time that 
% only depends on the image size, irrespective of the filter size.
%
% See also: INTEGRALFILTER, INTEGAVERAGE, INTFILTTRANSPOSE

% Reference: Crow, Franklin (1984). "Summed-area tables for texture
% mapping". SIGGRAPH '84. pp. 207-212. 
% Paul Viola and Michael Jones, "Robust Real-Time Face Detection",
% IJCV 57(2). pp 137-154. 2004.

% Copyright (c) 2006 Peter Kovesi
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

% October 2006

function intim = integralimage(im)
    
    if ndims(im) == 3
        error('Image must be greyscale');
    end
    
    if strcmp(class(im),'uint8')  % A cast to double is needed
        im = double(im);
    end
    
    intim = cumsum(cumsum(im,1),2);
% INTFILTTRANSPOSE - transposes an integral filter
%
% Usage: ft = intfilttranspose(f)
%
% Argument: f  - an integral image filter as described in the function INTEGRALFILTER
%
% Returns:  ft - a transposed version of the filter
%
% See also: INTEGRALFILTER, INTEGRALIMAGE, INTEGAVERAGE

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

function ft = intfilttranspose(f)
    
    [nfilt, dum] = size(f);
    ft = f;
    
    for n = 1:nfilt
        ft(n,1:4) = [f(n,2) -f(n,3) f(n,4) -f(n,1)];
    end
    
        
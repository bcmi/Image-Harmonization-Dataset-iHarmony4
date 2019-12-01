% BANDPASSFILTER - Constructs a band-pass butterworth filter
%
% usage: f = bandpassfilter(sze, cutin, cutoff, n)
% 
% where: sze    is a two element vector specifying the size of filter 
%               to construct [rows cols].
%        cutin and cutoff are the frequencies defining the band pass 0 - 0.5
%        n      is the order of the filter, the higher n is the sharper
%               the transition is. (n must be an integer >= 1).
%
% The frequency origin of the returned filter is at the corners.
%
% See also: LOWPASSFILTER, HIGHPASSFILTER, HIGHBOOSTFILTER
%

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

% October 1999


function f = bandpassfilter(sze, cutin, cutoff, n)
    
    if cutin < 0 | cutin > 0.5 | cutoff < 0 | cutoff > 0.5
	error('frequencies must be between 0 and 0.5');
    end
    
    if rem(n,1) ~= 0 | n < 1
	error('n must be an integer >= 1');
    end
    
    f = lowpassfilter(sze, cutoff, n) - lowpassfilter(sze, cutin, n);


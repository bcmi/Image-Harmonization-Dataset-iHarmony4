% HSVMAP Generates an HSV colourmap over a specified range of hues
%
% The function generates colours over a specified range of hues from the HSV
% colourtmap
%
% map = hsvmap(hmin, hmax, N)
%
% Arguments:  hmin - Minimum hue value 0 - 1. Default = 0
%             hmax - Maximum hue value 0 - 2. Default = 1 
%                N - Number of elements in the colourmap. Default = 256
%
% Note that hue values range from 0 to 1 in a cyclic manner.  hmax can be set to
% a value greater than one to allow one to specify a hue range that straddles
% the 0 point.  The resulting map is modulus 1. For example using
%   hmin = 0.9;
%   hmax = 1.1;
% Will generate hues ranging from 0.9 up to 1.0, followed by hues 0.0 to 0.1
%
% hsvmap(0, 1, 256) will generate a colourmap that is identical to MATLAB's hsv
% colourmap.
%
% See also: LABMAP, GRAYMAP, HSV, GRAY

% Copyright (c) 2012 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% March 2012

function map = hsvmap(hmin, hmax, N)
    
    if ~exist('N', 'var'),       N = 256;  end
    if ~exist('hmin', 'var'), hmin = 0;    end
    if ~exist('hmax', 'var'), hmax = 1; end
    
    assert(hmax<2, 'hmax must be less than 2');
    
    h = [0:(N-1)]'/(N-0)*(hmax-hmin)+hmin;
    h(h>1) = h(h>1)-1;  % Enforce hue wraparound 0-1
    
    map = hsv2rgb([h ones(N,2)]);
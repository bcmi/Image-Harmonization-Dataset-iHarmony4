% STARSINE Generates phase congruent star shaped sine wave grating
%
% Usage:    im = starsine(sze, nCycles, nScales, ampExponent, offset)
%
% Arguments:
%      sze         - The size of the square image to be produced.
%      nCycles     - The number of sine wave cycles around centre point.
%                    Typically an integer, but any value can be used.
%      nScales     - No of fourier components used to construct the
%                    signal. This is typically 1, if you want a simple sine
%                    wave, or >50 if you want to build a phase congruent
%                    waveform.
%      ampExponent - Decay exponent of amplitude with frequency.
%                    A value of -1 will produce amplitude inversely
%                    proportional to frequency (this will produce a step
%                    feature if offset is 0)
%                    A value of -2 with an offset of pi/2 will result in a
%                    triangular waveform.
%      offset      - Phase offset to apply to star pattern.
%
% Examples:
% nScales = 1             - You get a simple sine wave pattern radiating out
%                           from the centre. Use 'offset' if you wish to
%                           rotate it a bit.
% nScales 50, ampExponent -1, offset 0     - Square waveform
% nScales 50, ampExponent -2, offset pi/2  - Triangular waveform
% nScales 50, ampExponent -1.5, offset pi/4  - Something in between square and
%                                              triangular 
% nScales 50, ampExponent -1.5, offset 0   - Looks like a square but is not.
%
% See also: CIRCSINE, STEP2LINE

% Copyright (c) 2010 Peter Kovesi
% Centre for Exploration Targeting
% School of Earth and Enironment
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

% December 2010

function im = starsine(sze, nCycles, nScales, ampExponent, offset)

    if ~exist('offset', 'var')
	offset = 0;
    end
    
    % Place origin at centre for odd sized image, and below and the the
    % right of centre for an even sized image
    if mod(sze,2) == 0   % even sized image
	l = -sze/2;
	u = sze/2-1;
    else
	l = -(sze-1)/2;
	u = (sze-1)/2;
    end
    
    [x,y] = meshgrid(l:u);
    theta = atan2(y,x);

    im = zeros(size(theta));
    
    for scale = 1:2:(nScales*2 - 1)
        im = im + scale^ampExponent*sin(scale*nCycles*theta + offset);
    end
    
     
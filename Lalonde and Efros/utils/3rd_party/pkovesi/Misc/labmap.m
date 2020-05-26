% LABMAP - Generates a colourmap based on L*a*b* space
%
% Usage:  map = labmap(thetaMin, thetaMax, L, N)
%
% Arguments: thetaMin - Minimum and maximum angles in the a*b* plane over
%            thetaMax - which to define the colourmap (radians).
%                   L - Lightness, a value 0-100. Default = 60
%                   N - Number of elements in the colourmap. Default = 256.
%
% The colourmap is generated from a* and b* values that form a circle about
% the point (0, 0).  a* = cos(theta) and b* = sin(theta).
% a* +ve indicates magenta, a* -ve indicates green
% b* +ve indicates yellow, b* -ve indicates blue
%
% To specify hues that straddle theta = 0 use a thetaMax value that is
% greater than 2pi.
%
% In principle L*a*b* space is more perceptually uniform than, say, HSV
% space.  Thus it may be a better colourmap for some applications.
%
% See also: HSVMAP, GRAYMAP, HSV, GRAY

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


function map = labmap(thetaMin, thetaMax, L, N)
    
    if ~exist('N', 'var'),       N = 256;  end
    if ~exist('L', 'var'),       L = 60;   end
    if ~exist('thetaMin', 'var'), thetaMin = 0;    end
    if ~exist('thetaMax', 'var'), thetaMax = 2*pi; end
    
    theta = thetaMin:(thetaMax-thetaMin)/(N-1):thetaMax;
    lab = [L*ones(N,1) 127*cos(theta') 127*sin(theta')];
    map = applycform(lab, makecform('lab2srgb'));
    
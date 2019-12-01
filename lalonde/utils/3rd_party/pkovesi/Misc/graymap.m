% GRAYMAP Generates a gray colourmap over a specified range
%
% Usage: map = graymap(gmin, gmax, N)
%
% Arguments:  gmin, gmax - Minimum and maximum gray values desired in
%                          colourmap. Defaults are 0 and 1
%                      N - Number of elements in the colourmap. Default = 256.
%
% See also: HSVMAP, LABMAP, HSV, GRAY

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% peter.kovesi at uwa edu au

% March 2012


function map = graymap(gmin, gmax, N)
 
    if ~exist('gmin', 'var'),  gmin = 0;  end 
    if ~exist('gmax', 'var'),  gmax = 1;  end 
    if ~exist('N', 'var'),      N = 256;  end
    
    assert(gmin < gmax & gmin >= 0 & gmax <= 1, ...
           'gmin and gmax must be between 0 and 1');
    
    g = (0:N-1)'/(N-1) * (gmax-gmin) + gmin;
    map = [g g g];
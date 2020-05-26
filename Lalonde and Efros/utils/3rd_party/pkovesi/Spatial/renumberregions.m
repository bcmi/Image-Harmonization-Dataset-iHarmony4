% RENUMBERREGIONS
%
% Usage: nL = renumberregions(L)
%
% Argument:   L - A region segmented image, such as might be produced by a
%                 graph cut algorithm.  All pixels in each region are labeled
%                 by an integer.
%
% Returns:   nL - A relabeled version of L so that label numbers form a
%                 sequence 1:maxRegions
%
%
% Cleanupregions can leave an image with a non sequential numbering of regions 1 4 6 etc
% This function renumbers them to be 1 2 3 etc  so that calls to
% regionprops has no 'blank' entries in the resulting structure
% 0 values in the original image are left with the label 0
%
% See also: CLEANUPREGIONS, REGIONADJACENCY

% Copyright (c) 2010 Peter Kovesi
% Centre for Exploration Targeting
% School of Earth and Environment
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
% October 2010

function nL = renumberregions(L)
    

    nL = L;
    labels = unique(L(:))';  % Sorted list of unique labels
    
    % If there is a label of 0 ensure we do not renumber that region by
    % removing it from the list of labels to be renumbered
    if labels(1) == 0
        labels = labels(2:end);
    end
    
    % Now do the relabelling
    count = 1;
    for n = labels
        nL(L==n) = count;
        count = count+1;
    end
    
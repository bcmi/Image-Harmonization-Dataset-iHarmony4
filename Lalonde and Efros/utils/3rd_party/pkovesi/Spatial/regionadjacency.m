% REGIONADJACENCY  Computes adjacency matrix for an image of segmented regions
%
% Usage:  [Am, Al] = regionadjacency(L)
%
% Argument:   L - A region segmented image, such as might be produced by a
%                 graph cut algorithm.  All pixels in each region are labeled
%                 by an integer.
%
% Returns:   Am - An adjacency matrix indicating which labeled regions are
%                 adjacent to each other, that is, they share boundaries.
%            Al - A cell array representing the adjacency list corresponding
%                 to Am.  Al{n} is an array of the region indices adjacent to
%                 region n.
%
% Regions with a label of 0 are not considered.  If you want to include these
% regions you should assign a new positive label to these areas using, say
% >> L(L==0) = max(L(:)) + 1;
%
% Note that 8 connectivity is assumed.
%
% See also: CLEANUPREGIONS, RENUMBERREGIONS

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
% September 2010

function [Am Al Amm] = regionadjacency(L)
    
    % Identify the unique labels in the image, excluding 0 as a label.
    labels = setdiff(unique(L(:))',0);
    
    if isempty(labels)
        warning('There are no objects in the image')
        Am = [];
        Al = {};
        return
    end
    
    Am = zeros(max(labels));   % Allocate adjacency matrix
    Amm = Am;    
    Al = cell(1, max(labels)); % and adjacency list.

    % Strategy: Dilate each labeled region and use that as a mask on the
    % original labeled image.  This extracts the original region plus a one
    % pixel wide section of any adjacent regions.  This ends up in the image 'r'
    % in the code below. We then find the unique labels in 'r' ensuring the
    % label of the original region and 0 are not included in the label list.
    % This forms a list of region labels that are adjacent to the original
    % region.  We then set the entries in the adjacency list and adjacency
    % matrix accordingly.
    
    for n = labels
        r = zeros(size(L));
        r = L(imdilate(L==n, ones(3)));
        Al{n} = setdiff(unique(r(:)), [n 0]);
        Am(n, Al{n}) = 1;
        
        % Experimental: Get strength of 'adjacency' by counting No of pixels in
        % neighbouring region that is adjacent
        for m = Al{n}
            Amm(n,m) = sum(r(:)==m);
        end
        
    end
    
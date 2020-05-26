% CLEANUPREGIONS   Cleans up small segments in an image of segmented regions
%
% Usage: seg = cleanupregions(seg, areaThresh)
%
% Arguments: seg - A region segmented image, such as might be produced by a
%                  graph cut algorithm.  All pixels in each region are labeled
%                  by an integer.
%     areaThresh - Regions below this area in pixels will be merged with an
%                  adjacent segment.  I find a value of about 1/20th of the
%                  expected mean segment area, or 1/1000th of the image area
%                  usually looks 'about right'.
%
%  Note that regions with a label of 0 are ignored.  If you want these
%  regions to be considered you should assign a new positive label to these
%  areas using, say
%  >> L(L==0) = max(L(:)) + 1;
%
%  8 connectivity is assumed
%
% Returns:   seg - The updated segment image.
%
% Typical application:
% If a graph cut algorithm fails to converge stray segments can be left in the
% result.  This function tries to clean things up by:
% 1) Checking there is only one region for each segment label. If there is more
%    than one region they are given unique labels.
% 2) Eliminating regions below a specified size and assigning them a label of an
%    adjacent region.
%
% See also: REGIONADJACENCY, RENUMBERREGIONS

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

function seg = cleanupregions(seg, areaThresh, prioritySeg)

    if ~exist('prioritySeg','var'), prioritySeg = -1; end
    
    % 1) Ensure every segment is distinct but do not touch segments with a
    % label of 0
    labels = unique(seg(:))';
    maxlabel = max(labels);
    labels = setdiff(labels,0);  % Remove 0 from the label list
    
    for l = labels
        [bl,num] = bwlabel(seg==l,8);  % (Use 8 connectedness)
        
        if num > 1  % We have more than one region with the same label
            for n = 2:num
                maxlabel = maxlabel+1;  % Generate a new label
                seg(bl==n) = maxlabel;  % and assign to this segment
            end
        end
    end

    % 2) Merge segments with small areas
    stat = regionprops(seg,'area');  % Get segment areas
    area = cat(1, stat.Area);
    Am = regionadjacency(seg);       % Get adjacency matrix
    
    labels = unique(seg(:))';
    labels = setdiff(labels,0);  % Remove 0 from the label list
    for n = labels
        if ~isnan(area(n)) && area(n) < areaThresh 
            % Find regions adjacent to n and keep merging with the first element 
            % in the adjacency list until we obtain an area >= areaThresh, 
            % or we run out of regions to merge.
            ind = find(Am(n,:));

            while ~isempty(ind) && area(n) < areaThresh

                if ismember(prioritySeg, ind)
                    [seg, Am, area] = mergeregions(n, prioritySeg, seg, Am, area);
                    prioritySeg = n;
                else
                    [seg, Am, area] = mergeregions(n, ind(1), seg, Am, area);
                end
                
                ind = find(Am(n,:)); % (The adjacency matrix will have changed) 
            end
        end
    end
    
    % 3) As some regions will have been absorbed into others and no longer exist
    % we now renumber the regions so that they sequentially increase from 1
    seg = renumberregions(seg);
    
%-------------------------------------------------------------------
% Function to merge segment s2 into s1
% The segment image, Adjacency matrix and area arrays are updated.
% We could make this a nested function for efficiency but then it would not
% run under Octave.
function [seg, Am, area] = mergeregions(s1, s2, seg, Am, area)
    
    if s1==s2
        fprintf('s1 == s2!\n')
        return
    end
    
    % The area of s1 is now that of s1 and s2
    area(s1) = area(s1)+area(s2);
    area(s2) = NaN;
    
    % s1 inherits the adjacancy matrix entries of s2
    Am(s1,:) = Am(s1,:) | Am(s2,:);
    Am(:,s1) = Am(:,s1) | Am(:,s2);        
    
    Am(s1,s1) = 0;  % Ensure s1 is not connected to itself

    % Disconnect s2 from the adjacency matrix
    Am(s2,:) = 0;
    Am(:,s2) = 0;
    
    % Relabel s2 with s1 in the segment image
    seg(seg==s2) = s1;
    
    
% DRAWEDGELIST - plots pixels in edgelists
%
% Usage:    h =  drawedgelist(edgelist, rowscols, lw, col, figno)
%
% Arguments:
%    edgelist   - Cell array of edgelists in the form
%                     { [r1 c1   [r1 c1   etc }
%                        ...
%                        rN cN]   ....]
%    rowscols -   Optional 2 element vector [rows cols] specifying the size
%                 of the image from which edges were detected (used to set
%                 size of plotted image).  If omitted or specified as [] this
%                 defaults to the bounds of the linesegment points
%    lw         - Optional line width specification. If omitted or specified
%                 as [] it defaults to a value of 1;
%    col        - Optional colour specification. Eg [0 0 1] for blue.  This
%                 can also be specified as the string 'rand' to generate a
%                 random color coding for each edgelist so that it is easier
%                 to see how the edges have been broken up into separate
%                 lists. If omitted or specified as [] it defaults to blue
%    figno      - Optional figure number in which to display image.
%
% Returns:
%       h       - Array of handles to each plotted edgelist
%
% See also: EDGELINK, LINESEG

% Copyright (c) 2003-2011 Peter Kovesi
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

% February  2003 - Original version
% September 2004 - Revised and updated
% December  2006 - Colour and linewidth specification updated
% January   2011 - Axis setting corrected (thanks to Stzpz)

function h = drawedgelist(edgelist, rowscols, lw, col, figno)
    
    if nargin < 2, rowscols = [1 1]; end
    if nargin < 3, lw = 1; end
    if nargin < 4, col = [0 0 1]; end
    if nargin == 5, figure(figno);  end
    if isempty(rowscols), rowscols = [1 1]; end
    if isempty(lw), lw = 1; end
    if isempty(col), col = [0 0 1]; end    
    
    debug = 0;
    Nedge = length(edgelist);
    h = zeros(length(edgelist),1);
    
    if strcmp(col,'rand')
	colourmp = hsv(Nedge);    % HSV colour map with Nedge entries
	colourmp = colourmp(randperm(Nedge),:);  % Random permutation
	for I = 1:Nedge
	    h(I) = line(edgelist{I}(:,2), edgelist{I}(:,1),...
		 'LineWidth', lw, 'Color', colourmp(I,:));
	end	
    else
	for I = 1:Nedge
	    h(I) = line(edgelist{I}(:,2), edgelist{I}(:,1),...
		 'LineWidth', lw, 'Color', col);
	end	
    end

    if debug
	for I = 1:Nedge
	    mid = fix(length(edgelist{I})/2);
	    text(edgelist{I}(mid,2), edgelist{I}(mid,1),sprintf('%d',I))
	end
    end
    
    % Check whether we need to expand bounds
    minx = 1; miny = 1;
    maxx = rowscols(2); maxy = rowscols(1);

    for I = 1:Nedge
	minx = min(min(edgelist{I}(:,2)),minx);
	miny = min(min(edgelist{I}(:,1)),miny);
	maxx = max(max(edgelist{I}(:,2)),maxx);
	maxy = max(max(edgelist{I}(:,1)),maxy);	
    end	    

    axis('equal'); axis('ij');
    axis([minx maxx miny maxy]);
    
    if nargout == 0
        clear h
    end
    
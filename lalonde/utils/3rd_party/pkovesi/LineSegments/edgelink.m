% EDGELINK - Link edge points in an image into lists
%
% Usage: [edgelist edgeim] = edgelink(im, minlength, location)
%
% Arguments:  im         - Binary edge image, it is assumed that edges
%                          have been thinned.
%             minlength  - Optional minimum edge length of interest, defaults
%                          to 1 if omitted or specified as [].
%             location   - Optional complex valued image holding subpixel
%                          locations of edge points. For any pixel the
%                          real part holds the subpixel row coordinate of
%                          that edge point and the imaginary part holds
%                          the column coordinate.  See NONMAXSUP.  If
%                          this argument is supplied the edgelists will
%                          be formed from the subpixel coordinates,
%                          otherwise the the integer pixel coordinates of
%                          points in 'im' are used.
%
% Returns:  edgelist - a cell array of edge lists in row,column coords in
%                      the form
%                     { [r1 c1   [r1 c1   etc }
%                        r2 c2    ...
%                        ...
%                        rN cN]   ....]   
%
%           edgeim   - Image with pixels labeled with edge number. Note that
%                      this image also includes edges that do not meet the
%                      minimum length specification.  If you want to see just
%                      the edges that meet the specification you should pass
%                      the edgelist to DRAWEDGELIST.
%
%
% This function links edge points together into lists of coordinate pairs.
% Where an edge junction is encountered the list is terminated and a separate
% list is generated for each of the branches.
%
% See also:  DRAWEDGELIST, LINESEG, MAXLINEDEV, CLEANEDGELIST, FINDENDSJUNCTIONS
%
% Bugs: This code has caused me much grief on and off.  I keep discovering cases
% that do not get handled properly. The logic has grown in a way that is less
% structured than I would like.  At the moment I am aware that if there are two
% adjacent junction points things may go a bit astray.
%
% You may find a few edges that are needlessly broken into two, or more,
% segements.  This should be fixed up by CLEANEDGELIST which gets called if
% you specify a non-empty value for minlength.  Use a value of 0 if you want to
% fix this without trimming small edges.
%
% It may be that you encounter problems in the call to CLEANEDGELIST (which
% has perhaps caused me even more grief).  By calling edgelink with just the
% image arguments, or with an empty value for minlength, CLEANEDGELIST will
% not be called, and you will be spared any errors there.


% Acknowledgement:
% Some of this code is inspired by David Lowe's Link.c function from the
% Vista image processing library developed at the University of British
% Columbia 
%    http://www.cs.ubc.ca/nest/lci/vista/vista.html

% Copyright (c) 2001-2007 Peter Kovesi
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

% February  2001 - Original version
% September 2004 - Revised to allow subpixel edge data to be used
% November  2006 - Changed so that edgelists start and stop at every junction 
% January   2007 - Prefiltering to to discard isolated pixels and the
%                  problems they cause(thanks to Jeff Copeland)
% January   2007 - Fixes to ensure closed loops are closed, and a few other
%                  cases are handled better


function [edgelist, edgeim] = edgelink(im, minlength, location)
    
    global EDGEIM;      % Some global variables to avoid passing (and
                        % copying) of arguments, this improves speed.
    global ROWS;
    global COLS;
    global RJ;
    global CJ;
    
    EDGEIM = im ~= 0;                     % make sure image is binary.
    EDGEIM = bwmorph(EDGEIM,'clean');     % Remove isolated pixels
    EDGEIM = bwmorph(EDGEIM,'skel',Inf);  % and make sure edges are thinned. I
                                          % think using 'skel' is better than 'thin'    
    
    % Find endings and junctions in edge data
    [RJ, CJ, re, ce] = findendsjunctions(EDGEIM);

    EDGEIM = double(EDGEIM);   % Convert to double to allow the use of -ve labelings
    [ROWS, COLS] = size(EDGEIM);
    edgeNo = 0;
        
    % Perform raster scan through image looking for edge points.  When a
    % point is found trackedge is called to find the rest of the edge
    % points.  As it finds the points the edge image pixels are labeled
    % with the -ve of their edge No
    
    for r = 1:ROWS
        for c = 1:COLS
            if EDGEIM(r,c) == 1
                edgepoints = trackedge(r,c, edgeNo);
                if ~isempty(edgepoints)
                    edgeNo = edgeNo + 1;                    
                    edgelist{edgeNo} = edgepoints;
                end
            end
        end
    end
    
    edgeim = -EDGEIM;  % Finally negate image to make edge encodings +ve.

    
    % Eliminate isolated edges and spurs that are below the minimum length

    if nargin >= 2 && ~isempty(minlength)
        edgelist = cleanedgelist(edgelist, minlength);
    
    else  % Call cleanedgelist with 0 minlength anyway to fix spurrious nodes
          % that may exist due to problem with EDGELINK at points where
          % junctions are adjacent.
      %  edgelist = cleanedgelist(edgelist, 0);
    end
   
    
    % If subpixel edge locations are supplied upgrade the integer precision
    % edgelists that were constructed with data from 'location'.
    if nargin == 3
        for I = 1:length(edgelist)
            ind = sub2ind(size(im),edgelist{I}(:,1),edgelist{I}(:,2));
            edgelist{I}(:,1) = real(location(ind))';
            edgelist{I}(:,2) = imag(location(ind))';    
        end
    end
    
    
%----------------------------------------------------------------------    
% TRACKEDGE
%
% Function to track all the edge points associated with a start point.  From a
% given starting point it tracks in one direction, storing the coords of the
% edge points in an array and labelling the pixels in the edge image with the
% -ve of their edge number. This continues until no more connected points are
% found, or a junction point is encountered.  At this point the function returns
% to the start point and tracks in the opposite direction.
%
% Usage:   edgepoints = trackedge(rstart, cstart, edgeNo)
% 
% Arguments:   rstart, cstart   - row and column No of starting point
%              edgeNo           - the current edge number
%              minlength        - minimum length of edge to accept
%
% Returns:     edgepoints       - Nx2 array of row and col values for
%                                 each edge point.

function edgepoints = trackedge(rstart, cstart, edgeNo)
    
    global EDGEIM;
    global RJ;
    global CJ;
    global noPoint;
    global thereIsAPoint;
    global lastPoint;    

    noPoint = 0;
    thereIsAPoint = 1;
    lastPoint = 2;
    
    edgepoints = [rstart cstart];      % Start a new list for this edge.
    EDGEIM(rstart,cstart) = -edgeNo;   % Edge points in the image are 
                                       % encoded by -ve of their edgeNo.
    
    [status, r, c] = nextpoint(rstart,cstart, edgeNo); % Find next connected
                                                       % edge point.

    while status ~= noPoint
        edgepoints = [edgepoints             % Add point to point list
                       r    c   ];
        EDGEIM(r,c) = -edgeNo;               % Update edge image

        if status == lastPoint               % We have hit a junction point
            status = noPoint;                % make sure we stop tracking here
        else
            [status, r, c] = nextpoint(r,c, edgeNo); % Otherwise keep going
        end
    end

    % Now track from original point in the opposite direction - but only if
    % the starting point was not a junction point
    
    if ~isjunction(rstart,cstart)        
        % First reverse order of existing points in the edge list
        edgepoints = flipud(edgepoints);  
        
        % ...and start adding points in the other direction.
        [status, r, c] = nextpoint(rstart,cstart, edgeNo); 
        
        while status ~= noPoint
            edgepoints = [edgepoints
                          r    c   ];
            EDGEIM(r,c) = -edgeNo;
            if status == lastPoint
                status = noPoint;
            else
                [status, r, c] = nextpoint(r,c, edgeNo);
            end
        end
    end
    
    % Final check to see if this edgelist should have start and end points
    % matched to form a loop.  If the number of points in the list is four or
    % more (the minimum number that could form a loop), and the endpoints are
    % within a pixel of each other, append a copy if the first point to the
    % end to complete the loop
    
    if length(edgepoints) >= 4
        if abs(edgepoints(1,1) - edgepoints(end,1)) <= 1  &&  ...
           abs(edgepoints(1,2) - edgepoints(end,2)) <= 1 
            edgepoints = [edgepoints
                          edgepoints(1,:)];
        end
    end
    
    
    
%----------------------------------------------------------------------    
%
% NEXTPOINT
%
% Function finds a point that is 8 connected to an existing edge point
%

function [status, nextr, nextc] = nextpoint(rp,cp, edgeNo)

    global EDGEIM;
    global ROWS;
    global COLS;
    global RJ;
    global CJ;
    global noPoint;
    global thereIsAPoint;
    global lastPoint;        
    
    % row and column offsets for the eight neighbours of a point
    roff = [-1  0  1  0 -1 -1  1  1];
    coff = [ 0  1  0 -1 -1  1  1 -1];

    r = rp+roff;
    c = cp+coff;
    
    % Find indices of arrays of r and c that are within the image bounds
    ind = find((r>=1 & r<=ROWS) & (c>=1 & c<=COLS));
    
    % Search through neighbours and see if one is a junction point
    for i = ind 
        if (any(c(i) == CJ(RJ==r(i)))) && (EDGEIM(r(i),c(i)) ~= -edgeNo) 
            % This is a junction point that we have not marked as part of
            % this edgelist
            nextr = r(i);
            nextc = c(i);
            status = lastPoint;
            return;             % break out and return with the data
        end
    end
    
    % If we get here there were no junction points.  Search through neighbours
    % and return first connected edge point that itself has less than two
    % neighbours connected back to our current edge.  This prevents occasional
    % erroneous doubling back onto the wrong segment

    checkFlag = 0;
    for i = ind
        if EDGEIM(r(i),c(i)) == 1
            n = neighbours(r(i),c(i));
            if sum(n==-edgeNo) < 2
                nextr = r(i);
                nextc = c(i);
                status = thereIsAPoint;
                return;             % break out and return with the data
            
            else                    % Remember this point just in case we
                checkFlag = 1;      % have to use it
                rememberr = r(i);
                rememberc = c(i);               
            end
            
        end
    end
    
    % If we get here (and 'checkFlag' is true) there was no connected edge point
    % that had less than two connections to our current edge, but there was one
    % with more.  Use the point we remembered above.
    if checkFlag      
        nextr = rememberr;
        nextc = rememberc;
        status = thereIsAPoint;       
        return;                % Break out
    end
        
    % If we get here there was no connecting next point at all.
    nextr = 0;   
    nextc = 0;
    status = noPoint;

    
%------------------------------------------------------------------------
% Function to test whether a location in the image is a junction point.
% Note that for speed this code has been hard wired into NEXTPOINT.

function b = isjunction(r,c)
    global RJ;
    global CJ;
    
    b = any(c == CJ(RJ==r));
    
%------------------------------------------------------------------------
% Function to get the values of the 8 neighbouring pixels surrounding a point
% of interest.  The values are ordered from the top-left point going
% anti-clockwise around the pixel.
function n = neighbours(rp, cp)
    
    global EDGEIM;
    global ROWS;
    global COLS;

    % row and column offsets for the eight neighbours of a point
    roff = [-1  0  1  1  1  0 -1 -1];
    coff = [-1 -1 -1  0  1  1  1  0];
    
    r = rp+roff;
    c = cp+coff;
    
    % Find indices of arrays of r and c that are within the image bounds
    ind = find((r>=1 & r<=ROWS) & (c>=1 & c<=COLS));    

    n = zeros(1,8);
    for i = ind
        n(i) = EDGEIM(r(i),c(i));    
    end
    
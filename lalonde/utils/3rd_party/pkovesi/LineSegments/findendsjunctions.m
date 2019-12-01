% FINDENDSJUNCTIONS - find junctions and endings in a line/edge image
%
% Usage: [rj, cj, re, ce] = findendsjunctions(edgeim, disp)
% 
% Arguments:  edgeim - A binary image marking lines/edges in an image.  It is
%                      assumed that this is a thinned or skeleton image (or
%                      nearly so).
%             disp   - An optional flag 0/1 to indicate whether the edge
%                      image should be plotted with the junctions and endings
%                      marked.  This defaults to 0.
%
% Returns:    rj, cj - Row and column coordinates of junction points in the
%                      image. 
%             re, ce - Row and column coordinates of end points in the
%                      image.

% Copyright (c) 2006 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
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

% November 2006

function [rj, cj, re, ce] = findendsjunctions(edgeim, disp)

    if nargin == 1
	disp = 0;
    end
    
    % Ensure edge/line image really is thinnned otherwise tests for junctions
    % and endings may fail.
    b = bwmorph(edgeim,'skel',Inf);
    
    % Set up look up table to find junctions.  To do this we use the function
    % defined at the end of this file to test that the centre pixel within a 3x3
    % neighbourhood is a junction.
    lut = makelut(@junction, 3);
    junctions = applylut(b, lut);
    [rj,cj] = find(junctions);
    
    % Set up a look up table to find endings.  
    lut = makelut(@ending, 3);
    ends = applylut(b, lut);
    [re,ce] = find(ends);    

    if disp    
	show(edgeim,1), hold on
	plot(cj,rj,'r+')
	plot(ce,re,'g+')    
    end

%----------------------------------------------------------------------
% Function to test whether the centre pixel within a 3x3 neighbourhood is a
% junction. The centre pixel must be set and the number of transitions/crossings
% between 0 and 1 as one traverses the perimeter of the 3x3 region must be 6 or
% 8.
%
% Pixels in the 3x3 region are numbered as follows
%
%       1 4 7
%       2 5 8
%       3 6 9

function b = junction(x)
    
    a = [x(1) x(2) x(3) x(6) x(9) x(8) x(7) x(4)];
    b = [x(2) x(3) x(6) x(9) x(8) x(7) x(4) x(1)];    
    crossings = sum(abs(a-b));
    
    b = x(5) && crossings >= 6;
    
%----------------------------------------------------------------------
% Function to test whether the centre pixel within a 3x3 neighbourhood is an
% ending. The centre pixel must be set and the number of transitions/crossings
% between 0 and 1 as one traverses the perimeter of the 3x3 region must be 2.
%
% Pixels in the 3x3 region are numbered as follows
%
%       1 4 7
%       2 5 8
%       3 6 9

function b = ending(x)
    a = [x(1) x(2) x(3) x(6) x(9) x(8) x(7) x(4)];
    b = [x(2) x(3) x(6) x(9) x(8) x(7) x(4) x(1)];    
    crossings = sum(abs(a-b));
    
    b = x(5) && crossings == 2;
    
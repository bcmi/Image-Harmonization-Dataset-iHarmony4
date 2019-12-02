% HYSTHRESH - Hysteresis thresholding
%
% Usage: bw = hysthresh(im, T1, T2)
%
% Arguments:
%             im  - image to be thresholded (assumed to be non-negative)
%             T1  - upper threshold value
%             T2  - lower threshold value
%                   (T1 and T2 can be entered in any order, the larger of the
%                   two values is used as the upper threshold)
% Returns:
%             bw  - the thresholded image (containing values 0 or 1)
%
% Function performs hysteresis thresholding of an image.
% All pixels with values above threshold T1 are marked as edges
% All pixels that are connected to points that have been marked as edges
% and with values above threshold T2 are also marked as edges. Eight
% connectivity is used.

% Copyright (c) 1996-2005 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% http://www.csse.uwa.edu.au/
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% December 1996  - Original version
% March    2001  - Speed improvements made (~4x)
% April    2005  - Modified to cope with MATLAB 7's uint8 behaviour
% July     2005  - Enormous simplification and great speedup by realizing
%                  that you can use bwselect to do all the work

function bw = hysthresh(im, T1, T2)

    if T1 < T2    % T1 and T2 reversed - swap values 
	tmp = T1;
	T1 = T2; 
	T2 = tmp;
    end
    
    aboveT2 = im > T2;                     % Edge points above lower
                                           % threshold. 
    [aboveT1r, aboveT1c] = find(im > T1);  % Row and colum coords of points
                                           % above upper threshold.
					   
    % Obtain all connected regions in aboveT2 that include a point that has a
    % value above T1 
    bw = bwselect(aboveT2, aboveT1c, aboveT1r, 8);

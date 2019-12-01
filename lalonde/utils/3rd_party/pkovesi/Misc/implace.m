% IMPLACE - place image at specified location within larger image
%
% Usage: newim = implace(im1, im2, roff, coff)
%
% Arguments:
%
%       im1  - Image that im2 is to be placed in.
%       im2  - Image to be placed.
%       roff - Row and column offset of placement of im2 relative 
%       coff   to im1, (0,0) aligns top left corners.
%
% Warning: The class of final image matches the class of im1. If im1 is of
% type double and im2 is a uint8 colour image you will obtain a double image
% having 3 colour channels with values ranging between 0-255.  This will
% need to be cast to uint8, or divided by 255, for display via imshow or
% show.

% Copyright (c) 2004-2008 Peter Kovesi
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

% September 2004  Original version
% July      2008  Bug fixes for colour images

function newim = implace(im1, im2, roff, coff)
    
    [rows1, cols1, d] = size(im1);
    [rows2, cols2, d] = size(im2);    
    
    % Find min row and column of im2 that will appear in im1
    rmin2 = max(1,1-roff);
    cmin2 = max(1,1-coff);    
    
    % Find min row and column within im1 that im2 covers
    rmin1 = max(1,1+roff);
    cmin1 = max(1,1+coff);    
    
    % Find max row and column of im2 that will appear in im1    
    rmax2 = min(rows1-roff, rows2);
    cmax2 = min(cols1-coff, cols2);    
    
    % Find max row and column within im1 that im2 covers    
    rmax1 = min(rows2+roff, rows1);
    cmax1 = min(cols2+coff, cols1);    
    
    % Check for the case where there is no overlap of the images
    if rmax1 < 1 | cmax1 < 1 | rmax2 < 1 | cmax2 < 1 | ...
       rmin1 > rows1 | cmin1 > cols1 | rmin2 > rows2 | cmin2 > cols2

	newim = im1;  % Simply copy im1 to newim
	
    else  % Place im2 into im1
	
	% Check if either image is colour and if one needs promoting to colour
	ndim1 =  ndims(im1);
	ndim2 =  ndims(im2);    
	
	if ndim1 == 2 & ndim2 == 3
	    fprintf('promoting im1 \n');
	    im1 = uint8(repmat(im1,[1,1,3]));  % 'Promote' im1 to 3 channels
	    ndim1 = 3;
	elseif ndim2 == 2 & ndim1 == 3
	    fprintf('promoting im2 \n');
	    im2 = uint8(repmat(im2,[1,1,3]));  % 'Promote' im2 to 3 channels
	    ndim2 = 3;
	end
	
	newim = im1;
	
        if ndim1 ==2   % Greyscale
	    newim(rmin1:rmax1, cmin1:cmax1) = ...
                            im2(rmin2:rmax2, cmin2:cmax2);
	else           % Assume colour
	    newim(rmin1:rmax1, cmin1:cmax1,:) = ...
                            im2(rmin2:rmax2, cmin2:cmax2,:);	    
	end
	
    end
    

    
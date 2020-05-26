% INTERPFIELDS  - Interpolates lines on a field extracted from a video frame.
%
% Function to interpolate intermediate lines on odd or even
% fields extracted from a video frame
%
% Usage:   intp = interpfields(field, oddeven);
%
%
% Arguments:   field - the field to be interpolated
%              oddeven - optional flag 1/0 indicating whether the field
%                        is formed from the odd rows (default is 1)
%
% Returns:     interp - an image with extra rows inserted. These rows are
%                       obtained by averaging the rows above and below.
%                       A future enhancement might be to use bicubic
%                       interpolation.

% Copyright (c) 2000-2005 Peter Kovesi
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

% May 2000   - original version
% March 2004 - modified to use bicubic interpolation and to work for
%              colour images
% August 2004 - Corrected No of rows to interpolate to avoid NaNs in the result
% August 2005 - Made compatible under Octave

function intp = interpfields(field, oddeven);

    v = version; Octave = v(1)<'5';  % Crude Octave test
    
    if nargin==2
	if strcmp(oddeven, 'odd')
	    odd = 1;
	else
	    odd = 0;
	end
    else       % assume odd field
	odd = 1;
    end
    
    field = double(field);
    if ndims(field) == 3
	[rows, cols, depth] = size(field);
    elseif ndims(field) == 2
	[rows, cols] = size(field);
	depth = 1;
    else
	error('can only interpolate greyscale or colour images');
    end
    
    intp = zeros(2*rows-1,cols,depth);   
    
    [x,y]   = meshgrid(1:cols,1:2:2*rows-1); % coords at which data is defined.
    [xi,yi] = meshgrid(1:cols,1:2*rows-1);   % coords where we want data defined.
    
    for d = 1:depth
	if Octave
	    intp(:,:,d) = interp2(x,y,field(:,:,d),xi,yi,'linear');    
	else
	    intp(:,:,d) = interp2(x,y,field(:,:,d),xi,yi,'bicubic');    
	end
    end
    
    if odd                             % pad an extra row at the bottom
	intp = [intp;  field(rows,:,:)];
    else
	intp = [field(1,:,:); intp ];  % pad an extra row at the top
    end






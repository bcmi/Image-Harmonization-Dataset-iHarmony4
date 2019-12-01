% IMWRITESC - Writes an image to file, rescaling if necessary.
%
% Usage:   imwritesc(im,name)
%         
% Floating point image values are rescaled to the range 0-1 so that no
% overflow occurs when writing 8-bit intensity values.  The image format to
% use is determined by MATLAB from the file ending.
% If the image type is of uint8 no rescaling is performed.

% Copyright (c) 1999-2005 Peter Kovesi
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

% October 1999   - Original version
% March   2004   - Modified to allow colour images of class 'double'
% August  2005   - Octave compatibility

function imwritesc(im,name)

    v=version; Octave = v(1)<'5';   % Crude Octave test
    
    if strcmp(class(im), 'double')
	im = im - min(im(:));       % Offset so that min value is 0.
	im = im./max(im(:));        % Rescale so that max is 1.
    end
    
    if Octave    % Code specific to Octave and ImageMagick
	if strcmp(class(im), 'double')
	    im = 255*im;            % Rescale so that max is 255
	end	
	imwrite(name,im);          % Note Octave imwrite has args reversed
	
    else
        imwrite(im,name);
    end
    

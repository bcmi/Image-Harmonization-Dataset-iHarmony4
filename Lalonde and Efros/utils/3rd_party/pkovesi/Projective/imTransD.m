% IMTRANSD - Homogeneous transformation of an image.
%
% This is a stripped down version of imTrans which does not apply any origin
% shifting to the transformed image
%
% Applies a geometric transform to an image
%
%  newim = imTransD(im, T, sze, lhrh);
%
%  Arguments: 
%        im     - The image to be transformed.
%        T      - The 3x3 homogeneous transformation matrix.
%        sze    - 2 element vector specifying the size of the image that the
%                 transformed image is placed into.  If you are not sure
%                 where your image is going to 'go' make sze large! (though
%                 this does not help you if the image is placed at a negative
%                 location) 
%       lhrh    - String 'lh' or 'rh' indicating whether the transform was
%                 computed assuming columns represent x and rows represent y
%                 (a left handed coordinate system) or if it was computed
%                 using rows as x and columns as y (a right handed system,
%                 albeit rotated 90 degrees).  The default is assumed 'lh'
%                 though 'rh' is probably more sensible.
%
%
%  Returns:
%        newim  - The transformed image.
%
% See also: IMTRANS
%

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

% April 2000 - Original version.
% April 2010 - Allowance for left hand and right hand coordinate systems.
%              Offset of 1 pixel that was (incorrectly) applied in
%              transformImage removed.

function newim = imTransD(im, T, sze, lhrh);

    if ~exist('lhrh','var'), lhrh = 'l'; end
    
    if isa(im,'uint8')
        im = double(im);  % Make sure image is double     
    end
    
    if lhrh(1) == 'r'     % Transpose the image allowing for colour images
        im = permute(im,[2 1 3]);
    end
    
    threeD = (ndims(im)==3);  % A colour image
    if threeD    % Transform red, green, blue components separately
        im = im/255;  
        r = transformImage(im(:,:,1), T, sze);
        g = transformImage(im(:,:,2), T, sze);
        b = transformImage(im(:,:,3), T, sze);
        
        newim = repmat(uint8(0),[size(r),3]);
        newim(:,:,1) = uint8(round(r*255));
        newim(:,:,2) = uint8(round(g*255));
        newim(:,:,3) = uint8(round(b*255));
        
    else                % Assume the image is greyscale
        newim = transformImage(im, T, sze);
    end
    
    if lhrh(1) == 'r'   % Transpose back again
        newim = permute(newim,[2 1 3]);    
    end
    
%------------------------------------------------------------

% The internal function that does all the work

function newim = transformImage(im, T, sze);
    
    [rows, cols] = size(im);
    
    % Set things up for the image transformation.
    newim = zeros(rows,cols);
    [xi,yi] = meshgrid(1:cols,1:rows);    % All possible xy coords in the image.
        
    % Transform these xy coords to determine where to interpolate values
    % from. 
    Tinv = inv(T);
    sxy = homoTrans(Tinv, [xi(:)' ; yi(:)' ; ones(1,cols*rows)]);
    
    xi = reshape(sxy(1,:),rows,cols);
    yi = reshape(sxy(2,:),rows,cols);
    
    [x,y] = meshgrid(1:cols,1:rows);
 
%    x = x-1; % Offset x and y relative to region origin.
%    y = y-1; 
    newim = interp2(x,y,im,xi,yi); % Interpolate values from source image.
    
    % Place new image into an image of the desired size
    newim = implace(zeros(sze),newim,0,0);
    
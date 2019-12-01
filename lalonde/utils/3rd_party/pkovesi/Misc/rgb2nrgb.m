% RGB2NRGB - RGB to normalised RGB
%
% Usage: nrgb = rgb2nrgb(im, offset)
%
% Arguments:     im - Colour image to be normalised
%            offset - Optional value added to (R+G+B) to discount low
%                     intensity colour values. Defaults to 1
%
%  r =  R / (R + G + B)    etc

% Copyright (c) 2009 Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/

% May 2009

function nrgb = rgb2nrgb(im, offset)
 
    if ndims(im) ~= 3;
        error('Image must be a colour image');
    end

    % Convert to double if needed and define an offset = 1/255 max value to
    % be used in the normalization to avoid division by zero
    if ~strcmp(class(im), 'double')
        im = double(im);
        if ~exist('offset', 'var'), offset = 1; end
    else   % Assume we have doubles in range 0..1
        if ~exist('offset', 'var'), offset = 1/255; end
    end
    
    nrgb = zeros(size(im));
    gim = sum(im,3) + offset;

    nrgb(:,:,1) = im(:,:,1)./gim;
    nrgb(:,:,2) = im(:,:,2)./gim;
    nrgb(:,:,3) = im(:,:,3)./gim;            
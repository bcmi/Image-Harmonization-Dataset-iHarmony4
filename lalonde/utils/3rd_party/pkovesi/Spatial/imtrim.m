% IMTRIM - removes a boundary of an image
%
% Usage:  trimmedim = imtrim(im, b)
%
% Arguments:     im - Image to be trimmed (greyscale or colour)
%                 b - Width of boundary to be removed
%
% Returns: trimmedim - Trimmed image of size rows-2*b x cols-2*b
%
% See also: IMPAD, IMSETBORDER

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% June  2010

function tim = imtrim(im, b)

    assert(b >= 1, 'Padding size must be > 1')

    b = round(b);     % ensure integer
    [rows, cols, channels] = size(im);
    if rows <= 2*b || cols <= 2*b
        error('Amount to be trimmed is greater than image size');
    end
    tim = im(1+b:end-b, 1+b:end-b, 1:channels);
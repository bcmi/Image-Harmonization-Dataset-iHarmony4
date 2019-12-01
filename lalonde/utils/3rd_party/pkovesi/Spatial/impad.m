% IMPAD - adds zeros to the boundary of an image
%
% Usage:  paddedim = impad(im, b, v)
%
% Arguments:     im - Image to be padded (greyscale or colour)
%                 b - Width of padding boundary to be added
%                 v - Optional padding value if you do not want it to be 0.
%
% Returns: paddedim - Padded image of size rows+2*b x cols+2*b
%
% See also: IMTRIM, IMSETBORDER

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/
% June    2010
% January 2011  Added optional padding value

function pim = impad(im, b, v)

    assert(b >= 1, 'Padding size must be >= 1')
    if ~exist('v', 'var'), v = 0; end
    
    b = round(b);     % Ensure integer
    [rows, cols, channels] = size(im);
    if nargin == 3
        pim = v*ones(rows+2*b, cols+2*b, channels, class(im));
    else
        pim = zeros(rows+2*b, cols+2*b, channels, class(im));
    end
    
    pim(1+b:rows+b, 1+b:cols+b, 1:channels) = im;
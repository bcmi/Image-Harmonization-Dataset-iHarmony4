% IMSETBORDER - sets pixels on image border to a value 
%
% Usage:  im = imsetborder(im, b, v)
%
% Arguments:
%           im - image
%            b - border size 
%            v - value to set image borders to (defaults to 0)
%
% See also: IMPAD, IMTRIM

% Peter Kovesi
% Centre for Exploration Targeting
% The University of Western Australia
% http://www.csse.uwa.edu.au/~pk/research/matlabfns/

% June  2010

function im = imsetborder(im, b, v)
    
    if ~exist('v','var'),  v = 0;  end    

    assert(b >= 1, 'Padding size must be >= 1')
    b = round(b);  % ensure integer
    
    [rows,cols,channels] = size(im);
    for chan = 1:channels
        im(1:b,:,chan) = v;
        im(end-b+1:end,:,chan) = v;        
        im(:,1:b,chan) = v;
        im(:,end-b+1:end,chan) = v;                
    end
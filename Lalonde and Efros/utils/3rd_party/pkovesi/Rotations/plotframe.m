% PLOTFRAME - plots a coordinate frame specified by a homogeneous transform 
%
% Usage: function plotframe(T, len, label)
%
% Arguments:
%    T     - 4x4 homogeneous transform
%    len   - length of axis arms to plot (defaults to 1)
%    label - text string to append to x,y,z labels on axes
%
%  len and label are optional and default to 1 and '' respectively
%
% See also: ROTX, ROTY, ROTZ, TRANS, INVHT

% Copyright (c) 2001 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
% http://www.csse.uwa.edu.au/

function plotframe(T, len, label, colr)

    if ~all(size(T) == [4,4])
        error('plotframe: matrix is not 4x4')
    end
    
    if ~exist('len','var')
        len = 1;
    end
    
    if ~exist('label','var')    
        label = '';
    end
    
    if ~exist('colr','var')    
        colr = [0 0 1];
    end    
    
    % Assume scale specified by T(4,4) == 1
    
    origin = T(1:3, 4);             % 1st three elements of 4th column
    X = origin + len*T(1:3, 1);     % point 'len' units out along x axis
    Y = origin + len*T(1:3, 2);     % point 'len' units out along y axis
    Z = origin + len*T(1:3, 3);     % point 'len' units out along z axis
    
    line([origin(1),X(1)], [origin(2), X(2)], [origin(3), X(3)], 'color', colr);
    line([origin(1),Y(1)], [origin(2), Y(2)], [origin(3), Y(3)], 'color', colr);
    line([origin(1),Z(1)], [origin(2), Z(2)], [origin(3), Z(3)], 'color', colr);
    
    text(X(1), X(2), X(3), ['x' label], 'color', colr);
    text(Y(1), Y(2), Y(3), ['y' label], 'color', colr);
    text(Z(1), Z(2), Z(3), ['z' label], 'color', colr);
    

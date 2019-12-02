% HOMOTRANS - Homogeneous transformation of points/lines
%
% Function to perform a transformation on 2D or 3D homogeneous coordinates
% The resulting coordinates are normalised to have a homogeneous scale of 1
%
% Usage:
%           t = homotrans(P, v);
%
% Arguments:
%           P  - 3 x 3 or 4 x 4 homogeneous transformation matrix
%           v  - 3 x n or 4 x n matrix of homogeneous coordinates

% Copyright (c) 2000-2007 Peter Kovesi
% School of Computer Science & Software Engineering
% The University of Western Australia
% pk at csse uwa edu au
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

function t = homotrans(P, v);
    
    [dim,npts] = size(v);
    
    if ~all(size(P)==dim)
        error('Transformation matrix and point dimensions do not match');
    end

    t = P*v;            % Transform

    for r = 1:dim-1     %  Now normalise    
        t(r,:) = t(r,:)./t(end,:);
    end
    
    t(end,:) = ones(1,npts);
    
    

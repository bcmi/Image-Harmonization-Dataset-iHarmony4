% HOMOTRANS - homogeneous transformation of points
%
% Function to perform a transformation on homogeneous points/lines
% The resulting points are normalised to have a homogeneous scale of 1
%
% Usage:
%           t = homoTrans(P,v);
%
% Arguments:
%           P  - 3 x 3 or 4 x 4 transformation matrix
%           v  - 3 x n or 4 x n matrix of points/lines

%  Peter Kovesi
%  School of Computer Science & Software Engineering
%  The University of Western Australia
%  pk @ csse uwa edu au
%  http://www.csse.uwa.edu.au/~pk
%
%  April 2000
%  September 2007

function t = homotrans(P,v);
    
    [dim,npts] = size(v);
    
    if ~all(size(P)==dim)
	error('Transformation matrix and point dimensions do not match');
    end

    t = P*v;  % Transform

    for r = 1:dim-1     %  Now normalise    
	t(r,:) = t(r,:)./t(end,:);
    end
    
    t(end,:) = ones(1,npts);
    
    

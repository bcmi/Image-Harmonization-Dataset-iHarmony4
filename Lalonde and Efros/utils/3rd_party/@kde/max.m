function X = max(kde)
% X = max(p)
%   A simple estimate of the maximal peak location of p; returns the kernel location
%   with the largest density estimate.
%
% See also: kde, mean, getPoints

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

L = evaluate(kde,getPoints(kde));
[mx,mxind] = max(L);
X = getPoints(kde,mxind(1));

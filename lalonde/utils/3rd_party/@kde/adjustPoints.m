function adjustPoints(kde, delta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% adjustPoints(kde, delta) -- shift the points of kde by 'delta'
%                             delta should be [Ndim x Npts]
%
% -- note: kde is altered by reference through mex.
%
%  see also: kde, getPoints, getBW, adjustBW, getWeights, adjustWeights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%#mex

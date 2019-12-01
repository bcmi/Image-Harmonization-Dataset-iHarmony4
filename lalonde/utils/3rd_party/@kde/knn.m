function [neighbors, distance] = knn(kde,points,k)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% [neighbors, distance] = knn(kde,points,k)
%
%    Find the k nearest neighbors to the point set 'points' (an Ndim x Npts
%       double array) within the kde.  The neighbors are returned as a set
%       of indices (neighbors); the optional second return value is the
%       distance to the k^th nearest neighbor.  Note that the
%       nearest neighbor of a point can include the point itself,
%       i.e. a point of distance 0.
%
% See also:  kde, getPoints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%#mex
error('MEX-file kde/knn not found -- please recompile if necessary');

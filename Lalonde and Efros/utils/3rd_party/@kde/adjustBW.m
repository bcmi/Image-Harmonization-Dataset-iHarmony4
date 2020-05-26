function adjustBWs(npd,s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% adjustBWs(Pold,BW) -- change the bandwidths in NPD to S, which is
% either an (Ndims x 1) vector or an (Ndims x Npts) matrix.  You
% cannot change a kde with uniform bandwidths to one with variable
% bandwidths or vice versa.
%
%  see also: kde, getBW, getPoints, adjustPoints, getWeights, adjustWeights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%#mex
error(['MEX-file kde/adjustBWs not found -- please recompile if ' ...
       'necessary']);


%function p = adjustBW(npd,s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Pnew = adjustBW(Pold,BW)  -- make a new KDE from Pold with bandwidth BW
%
%  see also: kde, getBW, getPoints, adjustPoints, getWeights, adjustWeights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  p = kde(getPoints(npd),s,getWeights(npd),getType(npd));



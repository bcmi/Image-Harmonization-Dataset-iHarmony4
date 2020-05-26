function adjustWeights(npd,w)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% adjustWeights(Pold,W)  -- Change the weights of NPD to W, a (1 x
% Npts) vector.
%
% see also: getWeights, getPoints, adjustPoints, getBW, adjustBW, kde
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

%#mex
error(['MEX-file kde/adjustWeights not found -- please recompile if ' ...
       'necessary']);


%function p = adjustWeights(npd,w)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Pnew = adjustWeights(Pold,W)  -- create a new density from Pold with weights W
%
% see also: getWeights, getPoints, adjustPoints, getBW, adjustBW, kde
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  bw = .1;
%  if (size(kde.bandwidth,2)>2*kde.N), bw = getBW(npd,1:getNpts(npd));
%  else bw = getBW(npd,1); end;
%  p = kde(getPoints(npd),bw,w,getType(npd));

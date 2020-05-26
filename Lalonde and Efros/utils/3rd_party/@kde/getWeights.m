function wts = getWeights(dens,ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getWeights(P,ind)
%  returns the weights of the nonparametric density estimate P's kernels
%  specified by ind.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (nargin < 2) ind=1:dens.N; end;
  wts(double(dens.perm(dens.N + (1:dens.N)))+1) = dens.weights(dens.N + (1:dens.N));
  wts = wts(:,ind);
%  wts = dens.weights(:,dens.N + ind);

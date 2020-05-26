function pts = getPoints(dens,ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getPoints(P,ind)
%  returns the [Nd x Np] points of the nonparametric density estimate P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (nargin < 2) ind=1:dens.N; end;
  pts = zeros(dens.D,dens.N);
  pts(:,double(dens.perm(dens.N + (1:dens.N)))+1) = dens.centers(:,dens.N + (1:dens.N));
  pts = pts(:,ind);
%  pts = dens.centers(:,dens.N + ind);

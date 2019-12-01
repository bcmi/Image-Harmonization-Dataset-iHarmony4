function s = getBW(dens,ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% getBW(P,i) -- returns the [Nd x 1] std dev. (kernel size) associated with 
%               index i in the nonparametric density estimate P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (nargin < 2) ind=1:dens.N; end;
  s = zeros(dens.D,dens.N);
  s(:,double(dens.perm(dens.N + (1:dens.N)))+1) = dens.bandwidth(:,dens.N + (1:dens.N));
  s = s(:,ind);
  if (dens.type == 0) s = sqrt( s ); end;  % stddev for gaussian

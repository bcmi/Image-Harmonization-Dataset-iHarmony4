function ll = evalAvgLogL(dens,at,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% evalAvgLogL(P,Q [,...])  -- evaluate the mean log-likelihood of the KDE P
%                             at points Q ([Ndim x Npts] double or KDE)
%                             Optional flags are the same as evaluate
% See also: evaluate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if (isa(at,'kde'))
  L = evaluate(dens,at,varargin{:});
  W = getWeights(at);
  ind = find(L==0);
  if (any(W(ind))) ll=-inf;
  else
    L(ind) = 1;
    ll = (log(L)*W');
  end;
else
  L = evaluate(dens,at,varargin{:});
  if (length(find(L==0)))
    ll = inf;
  else
    ll = mean(log(L));
  end; 
end;

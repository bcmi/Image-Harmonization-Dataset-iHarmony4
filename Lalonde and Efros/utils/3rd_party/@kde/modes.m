function [modeList,attr] = modes(dens,start)
%
% [modes,assoc] = modes(kde [,init]) -- Find modes of a KDE via fixed point iter. scheme
%   options:
%    init -- initial locations for search (default is kde's kernel centers)
%   returns:
%    modes -- list of estimated mode locations
%    assoc -- which mode each initial location was attracted to
%
% NOTE: this process is not guaranteed to find all modes; while it stands an
%   excellent chance for Gaussian mixtures, KDEs consisting of Ep. or Lap. kernels
%   have discontinous derivatives, leading to quite "jagged" distributions, and
%   may have many more modes than kernel centers. See M. Carreira-Perpinan's webpage,
%   http://www.cs.toronto.edu/~miguel/research/GMmodes.html, for an excellent
%   discussion.
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if (nargin==1) start = getPoints(dens); end;

tol=1e-4; 					% set tolerance values etc. 
max_it=1000; 
minDistance = 1e-2;

pts = getPoints(dens); wts = getWeights(dens); start = start;
Ndim = size(pts,1); Npts = size(pts,2); Nloc = size(start,2);
BW = getBW(dens,1:Npts); bwMin = min(BW,[],2);
modeList = []; vals = [];

if (dens.type == 0)
  logBW = log(BW);                              % Cache log bandwidths for efficiency
end

for m=1:Nloc					% From each location given:
  x = start(:,m);				%   rename for convenience
  xTmp = x+inf;
  iter = 1;

  % FIXED POINT ITERATION TO FIND A MODE:
  while (tol < dist(x,xTmp,bwMin) && iter < max_it)	% Iterate until convergence:
    diff = pts - repmat(x,[1,Npts]);		%   get distance from kernel centers 
    xTmp = x;					%   and compute the update:

    if (dens.type == 0)				% GAUSSIAN
      K  = exp(sum(-.5*(diff./BW).^2-logBW,1)); %   compute kernel eval'n (missing 2pi)
      %K = prod(exp(-.5*(diff./BW).^2)./BW,1);	%   (slower kernel eval'n)
      px = wts * K';				%   compute kde eval  ( "" )
      x  = pts * (wts .* K)' ./ px;		%   compute recursion
    elseif (dens.type == 1)			% EPANETCHNIKOV (Mean-shift like update)
      K  = max(1-(diff./BW).^2,0)./BW;		%   compute kernel eval'n
      px = wts * prod(K,1)';			%   compute kde eval  ( "" )
      for d=1:Ndim,				%   compute update in each dimension
        Kd = wts .* prod(K([1:d-1,d+1:Ndim],:),1) .* (K~=0);
        Kd = Kd ./ sum(Kd);			%
        x(d) = pts(d,:) * Kd';			%
      end;
    else error('Sorry; KDE type not implemented');
    end;
    
    iter = iter + 1;				% increment and continue 
  end

  H = llHess(dens,x);				% Compute & 
  if max(eig(H)) < 0				% Check the Hessian: if it's
    modeList = [modeList,x]; vals = [vals,px];	%  neg. def. it's a mode; save it.
  end;

end

[tmp order] = sort(-vals);              % Sort by descending likelihd
modeList = modeList(:,order);			%
lookup=1:length(modeList); m = 1;       % Remove any redundant modes:
attr = 0*lookup; ok=[];
while (m < size(modeList,2))			%  start with "best" modes and
  ind = [m+1:size(modeList,2)];			%  work downwards:
  d = dist( modeList(:,ind), modeList(:,m+0*ind), bwMin(:,1+0*ind));
  ok  = find(d > minDistance);			%  remove any within minDistance
  modeList = modeList(:,[1:m,m+ok]); 	%   of a better mode   
  nok = find(d <= minDistance);
  attr(lookup([1,1+nok]))=m;
  lookup=lookup(1+ok);
  m = m+1;
end;
attr(lookup) = m;
attr(order) = attr;				% reverse sort operation for assoc.

function d=dist(x,y,bw)
  d = sqrt( sum( ((x-y)./bw).^2 ,1));

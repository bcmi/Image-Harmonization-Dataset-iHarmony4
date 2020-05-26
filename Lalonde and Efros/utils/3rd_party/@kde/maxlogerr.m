function [maxVal,location] = logerr(p,q)
%
% modes = logerr(p,q) -- Find location of max. log-error between p&q
%    
%
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

start = [getPoints(p),getPoints(q)];

tol=1e-4; 					% set tolerance values etc. 
max_it=1000; 
minDistance = 1e-2;

ppts = getPoints(p); pwts = getWeights(p); NptsP = size(ppts,2); pBW = getBW(p,1:NptsP); 
qpts = getPoints(q); qwts = getWeights(q); NptsQ = size(qpts,2); qBW = getBW(q,1:NptsQ); bwMin = min([pBW,qBW],[],2);
Ndim = size(ppts,1); Nloc = size(start,2);
modeList = []; vals = [];  bwmin = min([min(min(pBW)),min(min(qBW))]);

for m=1:Nloc					% From each location given:
  x = start(:,m);				%   rename for convenience
  xTmp = x+inf;
  iter = 1; alpha = .1;  dxprev = 0*x;
  
  % GRADIENT ASCENT TO FIND A MODE:
  while (tol < dist(x,xTmp,bwMin) && iter < max_it)	% Iterate until convergence:
    pdiff = ppts - repmat(x,[1,NptsP]);		%   get distance from kernel centers 
    qdiff = qpts - repmat(x,[1,NptsQ]);
    xTmp = x;					%   and compute the update:

    if (strcmp('GaussianGaussian',[getType(p),getType(q)]))
      Kp  = prod(exp(-.5*(pdiff./pBW).^2)./pBW,1);
      Kq  = prod(exp(-.5*(qdiff./qBW).^2)./qBW,1);
      px = pwts * Kp'; qx = qwts * Kq'; px = px + eps; qx = qx + eps;
      dx = (pdiff./ pBW.^2)*(pwts .* Kp)'./px - (qdiff./ qBW.^2)*(qwts .* Kq)'./qx;
      x = sign(log(px/qx)) * alpha * dx + x;
    else error('Sorry; KDE type(s) not implemented');
    end;
    if (min(dx .* dxprev)>0) alpha = alpha ./ .9; else alpha = .5*alpha; end;
    if (alpha < 1e-3) iter = inf; end;
    dxprev = dx;
        
    iter = iter + 1;				% increment and continue 
  end

%  if (iter < max_it)
    modeList = [modeList,x];      	%  save all extremum
    vals = [vals,abs(log(px/qx))];  %   and how extreme
%  end;
end

[vals,order] = sort(-vals);
modeList = modeList(:,order);

m = 1;						% Remove any redundant modes:
while (m < size(modeList,2))			%  start with "best" modes and
  ind = [m+1:size(modeList,2)];			%  work downwards:
  d = dist( modeList(:,ind), modeList(:,m+0*ind), bwMin(:,1+0*ind));	
  ok  = find(d > minDistance);			%  remove any within minDistance
  modeList = modeList(:,[1:m,m+ok]); 		%  of a better mode 
  vals = vals(:,[1:m,m+ok]);
  m = m+1;
end;
maxVal = -vals(1); location = modeList(:,1);


function d=dist(x,y,bw)
  d = sqrt( sum( ((x-y)./bw).^2 ,1));

function p = marginal(dens,ind)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% p = marginal(p2,ind) -- find the marginal of a kde on the given indices
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  pts = getPoints(dens);
  if (size(dens.bandwidth,2) > 2*dens.N)
    sig = getBW(dens,1:getNpts(dens));   % Many different BWs?
  else                                   % Or all BWs the same
    sig = getBW(dens,1);
  end;
  wts = getWeights(dens);
  p = kde(pts(ind,:),sig(ind,:),wts,getType(dens));

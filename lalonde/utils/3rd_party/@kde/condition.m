function p = condition(dens,ind,A)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% condition(P,i,A) -- find the conditional distr. P( x(~i) | x(i) = A(i))
%                     P is a KDE, i is a dimension index (e.g. [2,3]) and A
%                     is an [Ndim x 1] double
% 
% see also: kde
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (size(dens.bandwidth,2)>2*dens.N),   % variable BW case is complicated:
    wNew = zeros(1,getNpts(dens));
    for i=1:getNpts(dens),
      ktmp = kde(getPoints(dens,i),getBW(dens,i),1,getType(dens));
      wNew(i) = evaluate(marginal(ktmp,ind),A(ind),0);
    end;
  else 
    bw = getBW(dens,1); 
    wNew = evaluate( kde(A(ind),bw(ind),1,getType(dens)) , marginal(dens,ind) , 0);
  end;
%  wNew = wNew ./ sum(wNew);
  wNew = wNew .* getWeights(dens);
  pts = getPoints(dens);
  if (size(dens.bandwidth,2)>2*dens.N), bw = getBW(dens,1:getNpts(dens));
  else bw = getBW(dens,1); end;
  newInd = setdiff([1:getDim(dens)],ind);
  p = kde(pts(newInd,:),bw(newInd,:),wNew,getType(dens));
  

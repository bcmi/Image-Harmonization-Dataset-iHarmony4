function h = ksizeLSCV(npd)
% "Least-Squares Cross Validation" estimate (Silverman)
%

% Copyright (C) 2005 Alexander Ihler; distributable under GPL -- see README.txt

%  hROT = ksizeROT(npd);
%  npd = kde(getPoints(npd),hROT,getWeights(npd),getType(npd));
%  h =  golden(npd,@nLSCV,.1,1,30,1e-2);
%  h = h * hROT;

  [minm,maxm] = neighborMinMax(npd);
  npd = kde(getPoints(npd),(minm+maxm)/2,getWeights(npd),getType(npd));
  h =  golden(npd,@nLSCV,2*minm/(minm+maxm),1,2*maxm/(minm+maxm),1e-2);
  h = h * (minm+maxm)/2;
    
function [minm,maxm] = neighborMinMax(npd)
  maxm = sqrt(sum( (2*npd.ranges(:,1)).^2) );
  minm = min(sqrt(sum( (2*npd.ranges(:,1:npd.N-1)).^2 ,1)),[],2);
  minm = max(minm,1e-6);
    
function H = nLSCV(alpha,npd)  % only works for Gaussian kernels...
  if (nargin < 2) error('ksize: LSCV: Error!  Too few arguments'); end;
  if (npd.type == 0) alpha = alpha.^2; end;
  npd.bandwidth = npd.bandwidth * 2*alpha;
  H = mean(evaluate(npd,npd));		% drop factor of 2 from both
  npd.bandwidth = npd.bandwidth / 2;
  H = H - mean(evaluate(npd,npd,'lvout'));
  npd.bandwidth = npd.bandwidth / alpha;
  

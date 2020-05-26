function p2 = resample(p,Np,ksType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% resample(p,Np,KSType) -- construct a new estimate of the KDE p by sampling
%                      Np new points; determines a bandwidth by ksize(pNew,KSType)
%                      NOTE: KStype = 'discrete' resamples points by weight &
%                            preserves original kernel size
% see also: kde, ksize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  if (nargin < 3) ksType = 'rot'; end;
  if (nargin < 2) Np = getNpts(p); end;
  if (strcmp(ksType,'discrete'))
    q = kde(getPoints(p),zeros(getDim(p),1),getWeights(p)); 
    [samplePts,ind] = sample(q,Np);
    if (size(p.bandwidth,2)>2*p.N), ks = getBW(p,ind);
    else ks = getBW(p,1); end;
    p2 = kde(samplePts,ks);
  else
    samplePts = sample(p,Np);
    p2 = kde(samplePts,ksType);
  end;

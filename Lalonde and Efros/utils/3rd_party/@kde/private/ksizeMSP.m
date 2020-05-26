function h = ksizeMSP(npd,noIQR)
% "Maximal Smoothing Principle" estimate (Terrel '90)
%    Modified similarly to ROT for multivariate densities
%  Use ksizeMSP(X,1) to force use of stddev. instead of min(std,C*iqr)
%       (iqr = interquartile range, C*iqr = robust estimate of stddev)
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  X = getPoints(npd);
  N = size(X,2);
  if (nargin<2) noIQR=0; end;

  prop = 1.06;                  % See ksizeCalcUseful for derivation
  switch(npd.type),
      case 0, prop = 1.143896; % Gaussian
      case 1, prop = 2.532394; % Epanetchnikov
      case 2, prop = 0.847159; % Laplacian
  end;
  
  sig = std(X,0,2);            % estimate sigma (standard)
  if (noIQR)
    h = prop*sig*N^(-1/(4+length(sig)));
  else  
    iqrSig = .7413*iqr(X')';     % find interquartile range sigma est.
    if (max(iqrSig)==0) iqrSig=sig; end;
    h = prop * min(sig,iqrSig) * N^(-1/(4+length(iqrSig)));
  end;

%  if (min(h) == 0) warning('Near-zero covariance => Kernel size set to 0'); end;


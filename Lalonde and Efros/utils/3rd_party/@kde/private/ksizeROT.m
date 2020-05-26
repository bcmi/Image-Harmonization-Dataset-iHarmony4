function h = ksizeROT(npd,noIQR)
% "Rule of Thumb" estimate (Silverman)
%    Estimate is based on assumptions of Gaussian data and kernel
%    Actually the multivariate version in Scott ('92) 
%  Use ksizeROT(X,1) to force use of stddev. instead of min(std,C*iqr)
%       (iqr = interquartile range, C*iqr = robust stddev estimate)
%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

  X = getPoints(npd);
  N = size(X,2);  dim = size(X,1);
  if (nargin<2) noIQR=0; end;

  Rg = .282095; Mg=1;                     % See ksizeCalcUseful for derivation
  Re = .6;      Me = .199994;             %   this is the canonical kernel adjustment
  Rl = .25;     Ml = 1.994473;            %   for product kernels of these types
  switch(npd.type),
      case 0, prop = 1.0;                 % Approximate; 1D prop = 1.059224; % Gaussian
      case 1, prop = ((Re/Rg)^dim / (Me/Mg)^2 )^(1/(dim+4)); % 1D prop = 2.344944; % Epanetchnikov
      case 2, prop = ((Rl/Rg)^dim / (Ml/Mg)^2 )^(1/(dim+4)); % 1D prop = 0.784452; % Laplacian
  end;
  
  sig = std(X,0,2);            % estimate sigma (standard)
  if (noIQR)
    h = prop*sig*N^(-1/(4+dim));
  else  
    iqrSig = .7413*iqr(X')';     % find interquartile range sigma est.
    if (max(iqrSig)==0) iqrSig=sig; end;
    h = prop * min(sig,iqrSig) * N^(-1/(4+dim));
  end;

%  if (min(h) == 0) warning('Near-zero covariance => Kernel size set to 0'); end;

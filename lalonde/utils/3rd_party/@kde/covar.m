function cov = covar(dens,noBiasFlag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% covar(dens [,noBiasFlag]) --  returns the variance of a given KDE
%
%  if noBiasFlag = 1, this is the variance of the kernel locations themselves
%  Otherwise, it is the covariance of the density estimate (ie smoothed by the BW).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2003 Alexander Ihler; distributable under GPL -- see README.txt

if (nargin < 2) noBiasFlag = 0; end;
if (noBiasFlag)
  cov = var(getPoints(dens)',getWeights(dens)')';
else
  switch(dens.type),
    case 0, cov = dens.bandwidth(:,1);          % Gaussian: store variances.
    case 1, cov = .2 * dens.bandwidth(:,1).^2;  % Epanetch BW -> variance
    case 2, cov = 2 * dens.bandwidth(:,1).^2;   % Laplacian BW -> variance
  end;
end;

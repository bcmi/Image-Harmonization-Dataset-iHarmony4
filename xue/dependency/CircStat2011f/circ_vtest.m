function [pval v] = circ_vtest(alpha, dir, w, d)
%
% [pval, v] = circ_vtest(alpha, dir, w, d)
%   Computes V test for non-uniformity of circular data with a specified 
%   mean direction dir.
%   H0: the population is uniformly distributed around the circle
%   HA: the population is not distributed uniformly around the circle but
%   has a mean of dir.
%
%   Note: Not rejecting H0 may mean that the population is uniformly
%   distributed around the circle OR that it has a mode but that this mode
%   is not centered at dir.
%
%   The V test has more power than the Rayleigh test and is preferred if
%   there is reason to believe in a specific mean direction. 
%
%   Input:
%     alpha	sample of angles in radians
%     dir   suspected mean direction
%     [w		number of incidences in case of binned angle data]
%     [d    spacing of bin centers for binned data, if supplied 
%           correction factor is used to correct for bias in 
%           estimation of r, in radians (!)]
%
%   Output:
%     pval  p-value of V test
%     v     value of the V statistic
%
% PHB 7/6/2008
%
% References:
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html


if size(alpha,2) > size(alpha,1)
	alpha = alpha';
end

if nargin<3
  % if no specific weighting has been specified
  % assume no binning has taken place
	w = ones(size(alpha));
else
  if size(w,2) > size(w,1)
    w = w';
  end 
  if length(alpha)~=length(w)
    error('Input dimensions do not match.')
  end
end

if nargin<4
  % per default do not apply correct for binned data
  d = 0;
end

% compute some ingredients
r = circ_r(alpha,w,d);
mu = circ_mean(alpha,w);
n = sum(w);

% compute Rayleigh's R (equ. 27.1)
R = n * r;

% compute the V statistic (equ. 27.5)
v = R * cos(mu-dir);

% compute u (equ. 27.6)
u = v * sqrt(2/n);

% compute p-value from one tailed normal approximation
pval = 1 - normcdf(u);

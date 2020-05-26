function [h mu ul ll] = circ_mtest(alpha, dir, xi, w, d)
%
% [pval, z] = circ_mtest(alpha, dir, w, d)
%   One-Sample test for the mean angle.
%   H0: the population has mean dir.
%   HA: the population has not mean dir.
%
%   Note: This is the equvivalent to a one-sample t-test with specified
%         mean direction.
%
%   Input:
%     alpha	sample of angles in radians
%     dir   assumed mean direction
%     [xi   alpha level of the test]
%     [w		number of incidences in case of binned angle data]
%     [d    spacing of bin centers for binned data, if supplied 
%           correction factor is used to correct for bias in 
%           estimation of r, in radians (!)]
%
%   Output:
%     h     0 if H0 can not be rejected, 1 otherwise
%     mu    mean
%     ul    upper (1-xi) confidence level
%     ll    lower (1-xi) confidence level
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
  xi = 0.05;
end

if nargin<4
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

if nargin<5
  % per default do not apply correct for binned data
  d = 0;
end

% compute ingredients
mu = circ_mean(alpha,w);
t = circ_confmean(alpha,xi,w,d);
ul = mu + t;
ll = mu - t;

% compute test via confidence limits (example 27.3)
h = abs(circ_dist2(dir,mu)) > t;

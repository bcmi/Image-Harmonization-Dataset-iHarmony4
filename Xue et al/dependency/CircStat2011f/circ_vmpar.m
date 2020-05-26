function [thetahat kappa] = circ_vmpar(alpha,w,d)

% r = circ_vmpar(alpha, w, d)
%   Estimate the parameters of a von Mises distribution.
%
%   Input:
%     alpha	sample of angles in radians
%     [w		number of incidences in case of binned angle data]
%     [d    spacing of bin centers for binned data, if supplied 
%           correction factor is used to correct for bias in 
%           estimation of r, in radians (!)]
%
%   Output:
%     thetahat		preferred direction
%     kappa       concentration parameter
%
% PHB 3/23/2009
%
% References:
%   Statistical analysis of circular data, N.I. Fisher
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de

alpha = alpha(:);
if nargin < 2
  w = ones(size(alpha));
end
if nargin < 3
  d = 0;
end

r = circ_r(alpha,w,d);
kappa = circ_kappa(r);

thetahat = circ_mean(alpha,w);

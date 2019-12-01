function [k k0] = circ_kurtosis(alpha, w, dim)

% [k k0] = circ_kurtosis(alpha,w,dim)
%   Calculates a measure of angular kurtosis.
%
%   Input:
%     alpha     sample of angles
%     [w        weightings in case of binned angle data]
%     [dim      statistic computed along this dimension, 1]
%
%     If dim argument is specified, all other optional arguments can be
%     left empty: circ_kurtosis(alpha, [], dim)
%
%   Output:
%     k         kurtosis (from Pewsey)
%     k0        kurtosis (from Fisher)
%
%   References:
%     Pewsey, Metrika, 2004
%     Fisher, Circular Statistics, p. 34
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de

if nargin < 3
  dim = 1;
end

if nargin < 2 || isempty(w)
  % if no specific weighting has been specified
  % assume no binning has taken place
	w = ones(size(alpha));
else
  if size(w,2) ~= size(alpha,2) || size(w,1) ~= size(alpha,1) 
    error('Input dimensions do not match');
  end 
end

% compute mean direction
R = circ_r(alpha,w,[],dim);
theta = circ_mean(alpha,w,dim);
[mp, rho2, mu_p] = circ_moment(alpha,w,2,true,dim);
[mp, rho_p, mu2] = circ_moment(alpha,w,2,false,dim);

% compute skewness 
theta2 = repmat(theta, size(alpha)./size(theta));
k = sum(w.*(cos(2*(circ_dist(alpha,theta2)))),dim)./sum(w,dim);
k0 = (rho2.*cos(circ_dist(mu2,2*theta))-R.^4)./(1-R).^2;    % (formula 2.30)


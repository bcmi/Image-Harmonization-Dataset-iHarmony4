function [b b0] = circ_skewness(alpha, w, dim)

% [b b0] = circ_skewness(alpha,w,dim)
%   Calculates a measure of angular skewness.
%
%   Input:
%     alpha     sample of angles
%     [w        weightings in case of binned angle data]
%     [dim      statistic computed along this dimension, 1]
%
%     If dim argument is specified, all other optional arguments can be
%     left empty: circ_skewness(alpha, [], dim)
%
%   Output:
%     b         skewness (from Pewsey)
%     b0        alternative skewness measure (from Fisher)
%
%   References:
%     Pewsey, Metrika, 2004
%     Statistical analysis of circular data, Fisher, p. 34
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


% compute neccessary values
R = circ_r(alpha,w,[],dim);
theta = circ_mean(alpha,w,dim);
[~, rho2 mu2] = circ_moment(alpha,w,2,true,dim);

% compute skewness 
theta2 = repmat(theta, size(alpha)./size(theta));
b = sum(w.*(sin(2*(circ_dist(alpha,theta2)))),dim)./sum(w,dim);
b0 = rho2.*sin(circ_dist(mu2,2*theta))./(1-R).^(3/2);    % (formula 2.29)



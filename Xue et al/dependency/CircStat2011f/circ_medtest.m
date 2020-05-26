function pval = circ_medtest(alpha,md)
%
% [pval, z] = circ_medtest(alpha,w)
%   Tests for significance of the median.
%   H0: the population has median angle md
%   HA: the population has not median angle md
%
%   Input:
%     alpha	sample of angles in radians
%     md    median to test for
%
%   Output:
%     pval  p-value 
%
% PHB 3/19/2009
%
% References:
%   Biostatistical Analysis, J. H. Zar, 27.4
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

if size(alpha,2) > size(alpha,1)
	alpha = alpha';
end

if length(md)>1
  error('Median can only be a single value.')
end

n = length(alpha);

% compute deviations from median
d = circ_dist(alpha,md);

n1 = sum(d<0);
n2 = sum(d>0);

% compute p-value with binomial test
pval = sum(binopdf([0:min(n1,n2) max(n1,n2):n],n,0.5));





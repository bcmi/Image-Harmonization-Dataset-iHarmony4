function pval = circ_symtest(alpha)
%
% [pval, z] = circ_symtest(alpha,w)
%   Tests for symmetry about the median.
%   H0: the population is symmetrical around the median
%   HA: the population is not symmetrical around the median

%
%   Input:
%     alpha	sample of angles in radians
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

% compute median
md = circ_median(alpha);

% compute deviations from median
d = circ_dist(alpha,md);

% compute wilcoxon sign rank test
pval = signrank(d);





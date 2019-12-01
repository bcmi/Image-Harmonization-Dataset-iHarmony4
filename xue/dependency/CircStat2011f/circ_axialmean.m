function [r mu] = circ_axialmean(alphas, m, dim)
%
% mu = circ_axialmean(alpha, w)
%   Computes the mean direction for circular data with axial 
%   correction.
%
%   Input:
%     alpha	sample of angles in radians
%     [m		axial correction (2,3,4,...)]
%     [dim      statistic computed along this dimension, 1]
%
%   Output:
%     r		mean resultant length
%     mu		mean direction
%
% PHB 7/6/2008
%
% References:
%   Statistical analysis of circular data, N. I. Fisher
%   Topics in circular statistics, S. R. Jammalamadaka et al. 
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html
% Distributed under Open Source BSD License

if nargin < 3
  dim = 1;
end

if nargin < 2 || isempty(m)
    m = 1;
end

zbarm = mean(exp(1i*alphas*m),dim);

r = abs(zbarm);
mu = angle(zbarm)/m;


function [pval m] = circ_otest(alpha, sz, w)
%
% [pval, m] = circ_otest(alpha,sz,w)
%   Computes Omnibus or Hodges-Ajne test for non-uniformity of circular data.
%   H0: the population is uniformly distributed around the circle
%   HA: the population is not distributed uniformly around the circle
%
%   Alternative to the Rayleigh and Rao's test. Works well for unimodal,
%   bimodal or multimodal data. If requirements of the Rayleigh test are 
%   met, the latter is more powerful.
%
%   Input:
%     alpha	sample of angles in radians
%     [sz   step size for evaluating distribution, default 1 degree
%     [w		number of incidences in case of binned angle data]

%   Output:
%     pval  p-value 
%     m     minimum number of samples falling in one half of the circle
%
% PHB 3/16/2009
%
% References:
%   Biostatistical Analysis, J. H. Zar
%   A bivariate sign test, J. L. Hodges et al., 1955
%   A simple test for uniformity of a circular distribution, B. Ajne, 1968
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

if size(alpha,2) > size(alpha,1)
	alpha = alpha';
end

if nargin < 2 || isempty(sz)
  sz = circ_ang2rad(1);
end

if nargin < 3
  w = ones(size(alpha));
else
  if length(alpha)~=length(w)
    error('Input length does not match.')
  end
  w =w(:);  
end

alpha = mod(alpha,2*pi);
n = sum(w);
dg = 0:sz:pi;

m1 = zeros(size(dg));
m2 = zeros(size(dg));
for i=1:length(dg)
  m1(i) = sum((alpha > dg(i) & alpha < pi + dg(i)).*w);    
  m2(i) = n - m1(i);
end
m = min(min([m1;m2]));

if n > 50
  % approximation by Ajne (1968)
  A = pi*sqrt(n) / 2 / (n-2*m);
  pval = sqrt(2*pi) / A * exp(-pi^2/8/A^2);
else
  % exact formula by Hodges (1955)
  pval = 2^(1-n) * (n-2*m) * nchoosek(n,m);  
end

  
  










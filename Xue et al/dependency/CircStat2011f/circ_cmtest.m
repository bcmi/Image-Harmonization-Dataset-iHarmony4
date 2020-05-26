function [pval med P] = circ_cmtest(varargin)
%
% [pval, med, P] = circ_cmtest(alpha, idx)
% [pval, med, P] = circ_cmtest(alpha1, alpha2)
%   Non parametric multi-sample test for equal medians. Similar to a
%   Kruskal-Wallis test for linear data.
%
%   H0: the s populations have equal medians
%   HA: the s populations have unequal medians
%
%   Input:
%     alpha   angles in radians
%     idx     indicates which population the respective angle in alpha
%             comes from, 1:s
%
%   Output:
%     pval    p-value of the common median multi-sample test. Discard H0 if
%             pval is small.
%     med     best estimate of shared population median if H0 is not
%             discarded at the 0.05 level and NaN otherwise.
%     P       test statistic of the common median test.
%
%
% PHB 7/19/2009
%
% References:
%   Fisher NI, 1995
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

[alpha, idx] = processInput(varargin{:});

% number of groups
u = unique(idx);
s = length(u);

% number of samples
N = length(idx);

% total median
med = circ_median(alpha);

% compute relevant quantitites
n = zeros(s,1); m = n;
for t=1:s
  pidx = idx == u(t);
  n(t) = sum(pidx);
  
  d = circ_dist(alpha(pidx),med);
  
  m(t) = sum(d<0); 
end

if any(n<10)
  warning('Test not applicable. Sample size in at least one group to small.') %#ok<WNTAG>
end
  

M = sum(m);
P = (N^2/(M*(N-M))) * sum(m.^2 ./ n) - N*M/(N-M);

pval = 1 - chi2cdf(P,s-1);

if pval < 0.05
  med = NaN;
end




function [alpha, idx] = processInput(varargin)

if nargin==2 && sum(abs(round(varargin{2})-varargin{2}))>1e-5
  alpha1 = varargin{1}(:);
  alpha2 = varargin{2}(:);
  alpha = [alpha1; alpha2];
  idx = [ones(size(alpha1)); 2*ones(size(alpha2))];
elseif nargin==2
  alpha = varargin{1}(:);
  idx = varargin{2}(:);
  if ~(size(idx,1)==size(alpha,1))
    error('Input dimensions do not match.')
  end
else
  error('Invalid use of circ_wwtest. Type help circ_wwtest.')
end


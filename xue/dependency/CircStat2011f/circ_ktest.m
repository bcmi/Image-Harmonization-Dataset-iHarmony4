function [pval, f] = circ_ktest(alpha1, alpha2)
% [pval, f] = circ_ktest(alpha1, alpha2)
%
% A parametric two-sample test to determine whether two concentration 
% parameters are different.  
% 
%   H0: The two concentration parameters are equal.
%   HA: The two concentration parameters are different.
%
% Input: 
%   alpha1     fist sample (in radians)
%   alpha2     second sample (in radians)
%
% Output:
%   pval        p-value that samples have different concentrations
%   f           f-statistic calculated
%
% Assumptions: both samples are drawn from von Mises type distributions
%              and their joint resultant vector length should be > .7
% 
% References:
%   Batschelet, 1980, section 6.9, pg 122-124
%
% Circular Statistics Toolbox for Matlab

% By Marc J. Velasco, 2009
% velasco@ccs.fau.edu

alpha1 = alpha1(:);
alpha2 = alpha2(:);

n1 = length(alpha1);
n2 = length(alpha2);

R1 = n1*circ_r(alpha1);
R2 = n2*circ_r(alpha2);

% make sure that rbar > .7
rbar = (R1+R2)/(n1+n2);

if rbar < .7
    warning('resultant vector length should be > 0.7') %#ok<WNTAG>
end

% calculate test statistic
f = ((n2-1)*(n1-R1))/((n1-1)*(n2-R2));
if f > 1
  pval = 2*(1-fcdf(f, n1, n2));
else
  f = 1/f; 
  pval = 2*(1-fcdf(f, n2, n1));
end








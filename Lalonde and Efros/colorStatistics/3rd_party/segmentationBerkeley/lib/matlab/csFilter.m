function [f] = csFilter(sigma,support)
% function [f] = csFilter(sigma,support)
%
% Compute unit L1-norm zero-mean difference-of-Gaussians
% center-surround filter.
%
% INPUTS
%	sigma		2-element vector of inner/outer sigma.
%	[support]	Make filter +/- this many sigma.
%
% OUTPUTS
%	f	Square filter.
%
% David R. Martin <dmartin@eecs.berkeley.edu>
% March 2003

nargchk(1,2,nargin);
if nargin<2, support=3; end

if numel(sigma)~=2,
  error('sigma must have 2 elements');
end

% DOG
ratio = max(sigma) / min(sigma);
f1 = oeFilter(sigma(1),support*max(1,sigma(2)/sigma(1)));
f2 = oeFilter(sigma(2),support*max(1,sigma(1)/sigma(2)));
f = f1 - f2;

% zero mean
f = f - mean(f(:));

% unit L1-norm
sumf = sum(abs(f(:)));
if sumf>0,
  f = f / sumf;
end

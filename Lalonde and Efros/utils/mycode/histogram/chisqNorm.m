%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function chi = chisqNorm(hNorm,g)
%  Computes the chi-square statistic between two histograms. 
%
% Input parameters:
%   - hNorm: histogram 1 (normalized)
%   - g: histogram 2
%
% Output parameters:
%   - chi: the chi-square statistic
%
% Remarks:
%   - useful in a loop when a histogram is pre-normalized
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chi = chisqNorm(hNorm,g)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g = g./(sum(g(:))+eps);
t = ((hNorm-g).*(hNorm-g))./(hNorm+g+eps);
chi = 0.5*sum(t(:));



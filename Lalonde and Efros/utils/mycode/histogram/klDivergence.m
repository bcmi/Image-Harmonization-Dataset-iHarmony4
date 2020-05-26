%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function d = klDivergence(P, Q)
%   Computes the KL-divergence between the two (discrete) distributions P and Q. Solely computed
%   over the range of Q, that is, where Q is non-zero. <-- is that valid???
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = klDivergence(P, Q) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% both distributions must be the same size!
if size(P) ~= size(Q)
    error('Both distributions must be the same size!');
end

% D(P||Q) = sum p(x) log(p(x)/q(x))
d = sum(P(:) .* log(P(:) ./ Q(:)));

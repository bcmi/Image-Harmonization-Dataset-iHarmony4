%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function chi = chisqVec(h,g)
%  Computes the chi-square statistic from one histogram to M others. All 
%  histograms must be in column format
%
% Input parameters:
%   - h: histogram 1, Nx1 vector
%   - G: histograms 2, NxM vector
%
% Output parameters:
%   - chi: the chi-square statistic
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chi = chisqVec(h, G)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = repmat(h./(sum(h(:))+eps), 1, size(G,2));

% G = G./xrepmat(sum(G,1)+eps, size(G,1), 1); --> this creates a full matrix in sparse format: huge!
normG = sum(G,1)+eps;
for i=1:size(G,2)
    G(:,i) = G(:,i) ./ normG(i);
end

% t = ((h-G).*(h-G))./(h+G+eps); % --> watch out for memory problems
t = h-G;
t = t.*t;
% t = t ./ (h+G+eps); 
tDom = h+G;
clear h G;
t(t~=0) = t(t~=0) ./ (tDom(t~=0)+eps);
chi = 0.5*sum(t,1);


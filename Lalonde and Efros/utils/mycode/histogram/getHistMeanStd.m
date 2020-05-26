function [means, stds, centers, prctiles] = getHistMeanStd(x, y, edges)
% Computes the mean/stdev of data y within histogram bins defined by x.
% 
%   [means, stds, centers] = getHistMeanStd(x, y, <edges>)
%
% The output values will be 1x(n-1) where n=length(edges). When not
% specified, 'edges' will span the range of x, with 10 bins.
%
% See also:
%   histc
%
% ----------
% Jean-Francois Lalonde

if nargin < 3
    % automatically compute edges
    edges = linspace(min(x), max(x)+eps, 11);
end

[~,bin] = histc(x, edges);

maxBin = length(edges);
means = arrayfun(@(i) mean(y(bin==i)), 1:maxBin);
stds = arrayfun(@(i) std(y(bin==i)), 1:maxBin);

prctiles = arrayfun(@(i) prctile(y(bin==i), [25 50 75])', 1:maxBin, ...
    'UniformOutput', false);
prctiles = cat(2, prctiles{:});

means = means(1:end-1);
stds = stds(1:end-1);
prctiles = prctiles(:, 1:end-1);

centers = edges(1:end-1) + (edges(2:end) - edges(1:end-1))/2;


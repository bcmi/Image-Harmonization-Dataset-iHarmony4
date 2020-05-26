%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function plotSignatures(figureHandle, centers, weights, colorSpace)
%   Plot the signatures with points of size proportional to the weights of each center.
% 
% Input parameters:
%   - figureHandle: handle of figure where to draw the signature
%   - centers: cluster centers (typically obtained by k-means clustering)
%   - weights: weight of each cluster (nb of points associated with them, normalized)
%   - colorSpace: color space used to represent the centers (need inverse transformation to RGB)
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotSignatures(figureHandle, centers, weights, colorSpace)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(colorSpace, 'rgb')
    r = centers(:,1); g = centers(:,2); b = centers(:,3);
elseif strcmp(colorSpace, 'lab')
    [r,g,b] = lab2rgb(centers(:,1), centers(:,2), centers(:,3));
else
    error('Unsupported color space');
end

figure(figureHandle);
scatter3(centers(:,1), centers(:,2), centers(:,3), weights .* (200/max(weights)) + 1, [r g b]./255, 'filled');

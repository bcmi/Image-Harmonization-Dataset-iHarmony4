%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function weights = signaturesKmeans(data, nbClusters)
%  Computes signatures using k-means clustering, and return their weights (% of points belonging to
%  each cluster). Can be used in conjunction with EMD.
%
% Input parameters:
%   - data: input data NxD (N = nb points, D = dimensions)
%   - nbClusters: number of clusters to use
%
% Output parameters:
%   - centers: cluster centers (same dimension as input space)
%   - weights: weights of each cluster (% of points belonging to that cluster)
%   - inds: assignments for each point to a cluster center
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [centers, weights, inds] = signaturesKmeans(data, nbClusters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cluster the input data
[centers, inds] = vl_kmeans(data', nbClusters);
inds = inds';
centers = centers';

% count number of points in each cluster
counts = histc(inds, 1:nbClusters);

% drop the centers which do not contain any weight
% centers = centers';
if any(counts==0)
    centers = centers(counts > 0, :);
    nbClusters = size(centers, 1);

    % re-compute assignments
    inds = BruteSearchMex(centers', data');
    counts = histc(inds, 1:nbClusters);
end

% normalize and reshape 
weights = counts ./ sum(counts(:));


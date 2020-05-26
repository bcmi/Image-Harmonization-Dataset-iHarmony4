%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function 
%   
% 
% Input parameters:
%
% Output parameters:
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reweightedClusters = reweightClustersFromTextons(clusterWeights, textonWeights, indsCluster)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clusterTextonWeight = zeros(length(clusterWeights), 1);

for c=unique(indsCluster)'
    clusterTextonWeight(c) = sum(textonWeights(indsCluster == c));
end
% normalize such that the strongest response gets a weight of 1, and scale linearly
clusterTextonWeight = clusterTextonWeight ./ max(clusterTextonWeight);

reweightedClusters = clusterWeights .* clusterTextonWeight;

% re-normalize the weights
reweightedClusters = reweightedClusters ./ sum(reweightedClusters(:));

% EMD isn't happy when one weight is exactly equal to 0
reweightedClusters = reweightedClusters + eps;

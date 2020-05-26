function computeUniversalTextons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup paths
addpath ../;
setPath;

dbPath = '/nfs/hn01/jlalonde/results/colorStatistics';

nbClusters = 1000;

%% Load the pre-computed filter responses
load(fullfile(dbPath, 'illuminationContext', 'textons', 'globFilteredPx.mat'), 'globFilteredPx');

%% Reshape into a nbDims * nbPoints vector

% First, transpose
globFilteredPx = cellfun(@(x) x', globFilteredPx, 'UniformOutput', 0); %#ok

% Then, concatenate
globFilteredPx = [globFilteredPx{:}];

%% Keep only 1e6 points (out of ~9e6)
nbPoints = size(globFilteredPx, 2);
randInd = randperm(nbPoints);
globFilteredPx = globFilteredPx(:, randInd(1:1000000));

%% Run k-means on the remaining points
maxIters = 100;
minDelta = 1e-2;
verbose = 1;
fprintf('Running k-means for %d clusters...', nbClusters);
[clusterCenters, sse] = vgg_kmeans(globFilteredPx, nbClusters, 'maxiters', maxIters, 'mindelta', minDelta, 'verbose', verbose); %#ok
fprintf('done!\n');

save(fullfile(dbPath, 'illuminationContext', 'textons', sprintf('clusterCenters_%d.mat', nbClusters)), 'clusterCenters');


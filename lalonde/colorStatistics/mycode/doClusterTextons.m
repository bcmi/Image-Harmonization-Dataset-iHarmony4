%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doClusterTextons
%   Cluster all the 3x3 patches in the training database into textons
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doClusterTextons 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load the patches
addpath ../../3rd_party/vgg_matlab/vgg_general;
outputDir = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';

maxNbPatches = 1e5;

N = 5;
patchesFile = 'patches5x5_unsorted.mat';
centersFile = sprintf('clusterCenters%dx%d_%d_unsorted.mat', N, N, maxNbPatches);
 
fprintf('Loading patches...');
load(fullfile(outputDir, patchesFile));
fprintf('done.\n');

%% Run K-means on the patches
K = 10000;

ind = randperm(size(patches,1));

maxIters = 100;
minDelta = 1e-2;
verbose = 1;
fprintf('Running k-means over %d patches...', maxNbPatches);
[clusterCenters, sse] = vgg_kmeans(double(patches(ind(1:maxNbPatches),:)'), K, 'maxiters', maxIters, 'mindelta', minDelta, 'verbose', verbose);
fprintf('done!\n');


%% Save the cluster centers to file
fprintf('Saving the cluster centers to file...');
save(fullfile(outputDir, centersFile), 'clusterCenters');
fprintf('done.\n');

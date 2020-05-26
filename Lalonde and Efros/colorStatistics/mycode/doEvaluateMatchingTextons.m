%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingTextons
%   Evaluates whether an image matches its expected color distributions
%   (1st and 2nd order). Based on textons distributions
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingTextons 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';
addpath ../../3rd_party/parseArgs;

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataSemantic/testDataSemantic/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/testDataSemantic/';
trainingPath = '/nfs/hn01/jlalonde/results/colorStatistics/smallDataset/occurencesSmallDataset/occurencesTextons/';
subDirs = {'.'};

N = 5;

% histogram paths
histoPath1stOrder = fullfile(trainingPath, sprintf('cumulativeTextons1stOrderSparse%dx%d_100_unsorted.mat', N, N));
histoPath2ndOrder = fullfile(trainingPath, sprintf('cumulativeTextons2ndOrderSparse%dx%d_100_unsorted.mat', N, N));

% load the histograms
fprintf('Loading the cumulative histograms...');
total1stOrder = []; total2ndOrder = [];
load(histoPath1stOrder);
load(histoPath2ndOrder);
fprintf('done.\n');

% Normalize the histograms
cumulative1stOrder = cumulative1stOrder ./ sum(cumulative1stOrder(:));
% cumulative2ndOrder = cumulative2ndOrder ./ sum(cumulative2ndOrder(:));

% load the cluster centers
clustersPath = fullfile(trainingPath, sprintf('clusterCenters%dx%d_100000_unsorted.mat', N, N));
load(clustersPath);

dbFn = @dbFnEvaluateMatchingTextons;

% call the database function
processResultsDatabaseParallelFast(dbPath, outputBasePath, subDirs, dbFn, ...
    'Histo1stOrder', cumulative1stOrder, 'Histo2ndOrder', cumulative2ndOrder, ...
    'ClusterCenters', clusterCenters, 'N', N);


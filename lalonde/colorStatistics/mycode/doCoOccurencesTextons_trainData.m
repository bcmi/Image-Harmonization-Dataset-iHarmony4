%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCoOccurencesTextons
%   Computes the 1st and 2nd order statistics using 3x3 texton patches
% 
% Input parameters:
%
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCoOccurencesTextons_trainData 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelme/Images/';
annotationsBasePath = '/nfs/hn21/projects/labelme/Annotation/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/trainData/';

clusterCenterPath = '/nfs/hn01/jlalonde/results/colorStatistics/smallDataset/occurencesSmallDataset/occurencesTextons/';

% dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataJoint/';
% subDirs = {'.'};
% outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/testDataJoint/';

% read all the directories with the names 'static' and 'outdoor'
list = dir([imagesBasePath '*static*outdoor*']);
cellList = struct2cell(list);
subDirs = cellList(1,:);
% subDirs = {'april21_static_outdoor_davis'};

N = 5;
clusterCentersFile = sprintf('clusterCenters%dx%d_100000_unsorted.mat', N, N);

fprintf('Loading the cluster centers...');
load(fullfile(clusterCenterPath, clusterCentersFile));
fprintf('done.\n');

minArea = 0.05;
maxArea = 0.6;

dbFn = @dbFnCoOccurencesTextonsObjBg;

%% Call the database function
processDatabaseParallel(imagesBasePath, subDirs, annotationsBasePath, outputBasePath, dbFn, ...
    'ColorSpace', 'lab', 'ClusterCenters', clusterCenters, 'N', N, ...
    'MinArea', minArea, 'MaxArea', maxArea);
% processResultsDatabaseFast(dbPath, outputBasePath, subDirs, dbFn, ...
%     ColorSpace', 'lab', 'ClusterCenters', clusterCenters, 'N', N, ...
%     'MinArea', minArea, 'MaxArea', maxArea);

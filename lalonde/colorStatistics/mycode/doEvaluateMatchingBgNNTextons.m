%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingBgNNTextons
%   Evaluates the matching based on a nearest-neighbor on backgrounds approach. 
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingBgNNTextons%%
addpath '../database/';
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/testDataJoint/';
histoPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
outputPath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/testDataJoint/';
dbFn = @dbFnEvaluateMatchingBgNNTextons;
subDirs = {'images'};

N = 5;

% load the corresponding training data
fprintf('Loading the training data histograms...');
load(fullfile(histoPath, sprintf('trainDataTextons_%dx%d.mat', N, N)));
fprintf('done!\n');

% load the training database
trainingDbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/trainData/';
% read all the directories with the names 'static' and 'outdoor'
list = dir([trainingDbPath '*static*outdoor*']);
cellList = struct2cell(list);
trainingDbSubDirs= cellList(1,:);

fprintf('Loading the training database...');
% trainingDb = loadDatabase(trainingDbPath, trainingDbSubDirs);
% save(fullfile(trainingDbPath, 'trainingDb.mat'), 'trainingDb');
load(fullfile(trainingDbPath, 'trainingDb.mat'));
fprintf('done!\n');

histoObj = full(histoObj);

%%
processResultsDatabaseParallelFast(dbPath, outputPath, subDirs, dbFn, ...
    'HistoImg', histoImg, 'HistoBg', histoBg, 'HistoObj', histoObj, ...
    'IndObj', indObj, 'IndImg', indImg, 'TrainingDb', trainingDb, ...
    'IndImgGlob', indImgGlob);


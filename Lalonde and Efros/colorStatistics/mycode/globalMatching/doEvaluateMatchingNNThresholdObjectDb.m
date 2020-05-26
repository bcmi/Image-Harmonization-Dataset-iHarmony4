%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingNNThreshold
%   
% 
% Input parameters:
% 
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingNNThreshold(objectDb, realDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
dbPath = fullfile(basePath, 'dataset', 'filteredDb', 'Annotation');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'matchingEvaluationRealDb');

% colorSpaces = {'lab', 'lalphabeta'};
colorSpaces = {'lab'}; % lalphabeta is not ready yet (run doPrecomputeDistancesNN)
types = {'jointObj'};
compTypes = {'jointBg'};
dbFn = @dbFnEvaluateMatchingNNThresholdObjectDb;

%% Load the database
if nargin ~= 2
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
    
    load(fullfile(databasesPath, 'realDb.mat'));
end

%% Call the database function
parallelized = 1;
randomized = 1;
processDatabase(realDb, outputBasePath, dbFn, parallelized, randomized, 'document', 'image.filename', 'image.folder', ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ObjectDb', objectDb, ...
    'Types', types, 'CompTypes', compTypes);
% processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
%     'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ObjectDb', objectDb, ...
%     'Types', types, 'CompTypes', compTypes);

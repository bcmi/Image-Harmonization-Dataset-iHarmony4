%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingNNColorTextonThreshold
%   
% 
% Input parameters:
% 
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingNNColorTextonThreshold(objectDb)
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
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'matchingEvaluation');

% colorSpaces = {'lab', 'lalphabeta'};
colorSpaces = {'lab'}; % lalphabeta is not ready yet (run doPrecomputeDistancesNN)

% types, with corresponding complementary and texton types
types = {'jointObj', 'jointBg', 'margObj', 'margBg'};
compTypes = {'jointBg', 'jointObj', 'margBg', 'margObj'};
textonTypes = {'textonObj', 'textonBg', 'textonObj', 'textonBg'};
textonCompTypes = {'textonBg', 'textonObj', 'textonBg', 'textonObj'};

dbFn = @dbFnEvaluateMatchingNNColorTextonThreshold;

%% Load the database
if nargin ~= 1
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end

%% Call the database function
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ObjectDb', objectDb, ...
    'Types', types, 'CompTypes', compTypes, 'TextonTypes', textonTypes, 'TextonCompTypes', textonCompTypes);

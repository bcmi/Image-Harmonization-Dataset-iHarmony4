%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingNN
%   Evaluates whether an image matches its expected color distributions
%   (1st and 2nd order). Based solely on histogram comparison.
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
function doEvaluateMatchingNN(objectDb)
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
types = {'jointObj', 'jointBg', 'margObj', 'margBg'};
compTypes = {'jointBg', 'jointObj', 'margBg', 'margObj'};
dbFn = @dbFnEvaluateMatchingNN;

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
    'Types', types, 'CompTypes', compTypes);

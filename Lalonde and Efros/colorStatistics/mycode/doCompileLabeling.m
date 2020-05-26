%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileLabeling
%   Scripts that compiles the labelings
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileLabeling(doSkipXml)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
setPath;

if nargin ~= 1
    doSkipXml = 0;
end

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
dbPath = fullfile(basePath, 'dataset', 'filteredDb', 'Annotation');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingEvaluation/compiledResults/';

dbFn = @dbFnCompileLabeling;

% define and initialize the scores
global isGenerated imageLabel;

files = getFilesFromSubdirectories(dbPath, '', 'xml');
nbImages = length(files);

isGenerated = zeros(nbImages, 1);
imageLabel = zeros(nbImages, 1);

%% Load the database
if doSkipXml
    fprintf('Loading synthetic database...'); tic;
    load(fullfile(databasesPath, 'syntheticDb.mat'));
    fprintf('done in %fs.\n', toc);
else
    fprintf('Loading matching evaluation database from xml...'); tic;
    syntheticDb = loadDatabaseFast(dbPath, '');
    save(fullfile(databasesPath, 'syntheticDb.mat'), 'syntheticDb');
    fprintf('done in %fs.\n', toc);
end

%% Loop over the database results
% call the database function
parallelized = 0;
randomized = 0;
processDatabase(syntheticDb, outputBasePath, dbFn, parallelized, randomized, ...
    'document', 'image.filename', 'image.folder');

delete(fullfile(outputBasePath, 'labelings.mat'));
save(fullfile(outputBasePath, 'labelings.mat'), 'isGenerated', 'imageLabel');
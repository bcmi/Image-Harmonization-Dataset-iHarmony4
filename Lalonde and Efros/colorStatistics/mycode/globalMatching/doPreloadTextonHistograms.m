%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPreloadTextonHistograms
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPreloadTextonHistograms(objectDb, imageDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
objectDbPath = fullfile(basePath, 'objectDb');
imageDbPath = fullfile(basePath, 'imageDb');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'globalMeasures', 'concatHistoTextons');

dbFn = @dbFnPreloadTextonHistograms;
types = {'textonObj', 'textonBg'};

maxSizeMB = 500;

%% Load the databases and indices
if nargin ~= 2
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
    
    fprintf('Loading the image database...');
    load(fullfile(databasesPath, 'imageDb.mat'));
    fprintf('done.\n');
end
load(fullfile(databasesPath, 'objImgIndices.mat'));

%% call the database function over each color space independently
global concatHisto;
for t=1:length(types)
    concatHisto = cell(length(objectDb), 1);

    % overwrite whatever was already there
    delete(fullfile(outputBasePath, sprintf('concatHisto_%s*', types{t})));

    parallelized = 0;
    randomized = 0;
    processDatabase(objectDb, outputBasePath, dbFn, parallelized, randomized, ...
        'document', 'image.filename', 'image.folder', 'ObjectDbPath', objectDbPath, ...
        'Type', types{t}, 'MaxSizeMB', maxSizeMB, 'Dims', length(objectDb), ...
        'ImageDb', imageDb, 'ImageDbPath', imageDbPath, 'ObjectToImageInd', objectToImageInd);

    % save the concatenated histogram
    nb = 0;
    files = dir(fullfile(outputBasePath, sprintf('concatHisto_%s*', types{t})));
    if length(files)
        str = sprintf('concatHisto_%s_%%04d.mat', types{t});
        nb = sscanf(files(end).name, str) + 1;
    end

    outputFile = fullfile(outputBasePath, sprintf('concatHisto_%s_%04d.mat', types{t}, nb));
    fprintf('Saving final part %s...\n', outputFile);
    save(outputFile, 'concatHisto');
end


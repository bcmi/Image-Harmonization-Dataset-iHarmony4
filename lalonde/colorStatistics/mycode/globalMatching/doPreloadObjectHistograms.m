%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPreloadObjectHistograms
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPreloadObjectHistograms(objectDb)
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
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'globalMeasures', 'concatHisto');

dbFn = @dbFnPreloadObjectHistograms;
colorSpaces = {'lab', 'lalphabeta'};
% colorSpaces = {'lalphabeta'};
types = {'jointObj', 'jointBg', 'margObj', 'margBg'};

maxSizeMB = 500;

%% Load the database
if nargin ~= 1
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end

%% call the database function over each color space independently
global concatHisto;
for i=1:length(colorSpaces)
    for t=1:length(types)
        concatHisto = cell(length(objectDb), 1);
        
        % overwrite whatever was already there
        delete(fullfile(outputBasePath, sprintf('concatHisto_%s_%s', colorSpaces{i}, types{t})));
        
        parallelized = 0;
        randomized = 0;
        processDatabase(objectDb, outputBasePath, dbFn, parallelized, randomized, ...
            'document', 'image.filename', 'image.folder', 'ObjectDbPath', objectDbPath, ...
            'ColorSpace', colorSpaces{i}, 'Type', types{t}, ...
            'MaxSizeMB', maxSizeMB, 'Dims', length(objectDb));
        
        % save the concatenated histogram
        nb = 0;
        files = dir(fullfile(outputBasePath, sprintf('concatHisto_%s_%s*', colorSpaces{i}, types{t})));
        if length(files)
            str = sprintf('concatHisto_%s_%s_%%04d.mat', colorSpaces{i}, types{t});
            nb = sscanf(files(end).name, str) + 1;
        end

        outputFile = fullfile(outputBasePath, sprintf('concatHisto_%s_%s_%04d.mat', colorSpaces{i}, types{t}, nb));
        fprintf('Saving final part %s...\n', outputFile);
        save(outputFile, 'concatHisto');
    end
end


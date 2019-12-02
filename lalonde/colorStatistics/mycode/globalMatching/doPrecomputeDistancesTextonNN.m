%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeDistancesTextonNN
%   Pre-compute the distances from each image in the synthetic dataset to every other image
%   in the database
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeDistancesTextonNN(objectDb)
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
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation'); 
imagesPath = fullfile(dbBasePath, 'Images');
objectDbPath = fullfile(basePath, 'objectDb');
imageDbPath = fullfile(basePath, 'imageDb');
databasesPath = fullfile(basePath, 'databases');
concatHistoPath = fullfile(basePath, 'globalMeasures', 'concatHistoTextons');

outputBasePath = dbPath;

dbFn = @dbFnPrecomputeDistancesTextonNN;

types = {'textonObj', 'textonBg'};

if nargin ~= 1
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end

global lockAppend;

for t=1:length(types)
    % get the number of concatenated histograms
    nb = 0;
    files = dir(fullfile(concatHistoPath, sprintf('concatHisto_%s*', types{t})));
    if length(files)
        str = sprintf('concatHisto_%s_%%04d.mat', types{t});
        nb = sscanf(files(end).name, str);
    end

    for j=0:nb
        histoPath = fullfile(concatHistoPath, sprintf('concatHisto_%s_%04d.mat', types{t}, j));
        fprintf('Loading %s...\n', histoPath);
        load(histoPath);

        % call the database function
        parallelized = 1;
        randomized = 1;
        lockAppend = sprintf('%s_%d', types{t}, j);
        processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
            'DbPath', dbPath, 'ObjectDbPath', objectDbPath, 'ImageDbPath', imageDbPath, ...
            'ImagesPath', imagesPath, 'ConcatHisto', concatHisto, 'Type', types{t}, ...
            'NbDistances', length(objectDb), 'SyntheticDbPath', dbPath);

        % clear the histogram
        clear('concatHisto');
    end
end

function doEvaluateIlluminationContext 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath ../;
setPath;

% define the paths
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/';
syntheticDbBasePath = fullfile(dbPath, 'dataset', 'combinedDb');
syntheticDbPath = fullfile(syntheticDbBasePath, 'Annotation');
syntheticImagesPath = fullfile(syntheticDbBasePath, 'Images');

outputBasePath = fullfile(dbPath, 'illuminationContext', 'results');
imageDbPath = fullfile(dbPath, 'imageDb');

dbFn = @dbFnEvaluateIlluminationContext;

% call the database
parallelized = 0;
randomized = 0;
processResultsDatabaseFast(syntheticDbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', subsampledImagesPath, 'SyntheticImagesPath', syntheticImagesPath, ...
    'ImageDbPath', imageDbPath);
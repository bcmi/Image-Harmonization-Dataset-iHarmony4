%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doComputeColorMatching
%  Computes color histogram matching on sliding windows over the entire image
%  (analogous to texton matching, but with color)
%   
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doComputeColorMatching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
setPath;

% define the paths
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
imageDbPath = fullfile(basePath, 'imageDb');
objectDbPath = fullfile(basePath, 'objectDb');
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');

outputBasePath = dbPath;
dbFn = @dbFnComputeColorMatching;

% call the database
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', imagesPath, 'SubsampledImagesPath', subsampledImagesPath, ...
    'ImageDbPath', imageDbPath, 'SyntheticDbPath', dbPath, 'ObjectDbPath', objectDbPath);



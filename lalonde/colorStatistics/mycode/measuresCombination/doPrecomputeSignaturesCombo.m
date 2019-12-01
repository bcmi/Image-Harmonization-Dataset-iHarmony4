%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeSignaturesCombo
% 
% Input parameters:
%
% Output parameters:
%
% Notes:
%  - Only works in Lab color space
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeSignaturesCombo
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

dbFn = @dbFnPrecomputeSignaturesCombo;

sigmas = 5:5:100;

% call the database function
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', dbPath, dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'ImagesPath', imagesPath, 'Sigmas', sigmas);


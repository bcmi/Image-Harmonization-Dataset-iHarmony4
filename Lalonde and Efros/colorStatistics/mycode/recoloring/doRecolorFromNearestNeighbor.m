%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doRecolorFromNearestNeighbor
%   
% 
% Input parameters:
% 
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doRecolorFromNearestNeighbor(objectDb)
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
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'recoloring', 'jointBg');
objectDbPath = fullfile(basePath, 'objectDb');

colorSpaces = {'lab'}; 

% types, with corresponding complementary and texton types
types = {'jointBg'};
compTypes = {'jointObj'};
textonTypes = {'textonObj'};

nbClusters = 100;

dbFn = @dbFnRecolorFromNearestNeighbor;

%% Load the database
if nargin ~= 1
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end

%% Call the database function
parallelized = 0;
randomized = 1;
processResultsDatabaseFast(dbPath, 'image_0', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ObjectDb', objectDb, 'ObjectDbPath', objectDbPath, ...
    'Types', types, 'CompTypes', compTypes, 'TextonTypes', textonTypes, ...
    'SubsampledImagesPath', subsampledImagesPath, 'NbClusters', nbClusters, ...
    'ImagesPath', imagesPath);

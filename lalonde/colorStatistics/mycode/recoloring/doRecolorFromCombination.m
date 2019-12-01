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
function doRecolorFromCombination(objectDb, syntheticDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled800/Images';
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = dbPath;
% outputBasePath = fullfile(basePath, 'recoloring', 'supplementaryMaterial');
% outputHtmlPath = fullfile('colorStatistics', 'recoloring', 'supplementaryMaterial');
objectDbPath = fullfile(basePath, 'objectDb');

colorSpaces = {'lab'}; 

% types, with corresponding complementary and texton types
types = {'jointBg'};
compTypes = {'jointObj'};
textonTypes = {'textonBg'};
textonCompTypes = {'textonObj'};

nbClusters = 100;

dbFn = @dbFnRecolorFromCombination;

%% Setup html stuff
% htmlInfo = [];
% [htmlInfo.experimentNb, htmlInfo.outputDirExperiment, htmlInfo.outputDirFig, ...
%     htmlInfo.outputDirJpg, htmlInfo.outputHtmlFileName] = setupBatchTest(outputHtmlPath, '');


%% Load the database
if nargin ~= 2
    fprintf('Loading the databases...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    load(fullfile(databasesPath, 'syntheticDb.mat'));
    fprintf('done.\n');
end

% load the indices 
load(fullfile(databasesPath, 'userIndicesTrainTest.mat'));

%% Call the database function
parallelized = 1;
randomized = 1; 

indices = [indRealistic; indUnrealistic; indReal];

processDatabase(syntheticDb(indices), outputBasePath, dbFn, parallelized, randomized, 'document', 'image.filename', 'image.folder', ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ObjectDb', objectDb, 'ObjectDbPath', objectDbPath, ...
    'Types', types, 'CompTypes', compTypes, 'TextonTypes', textonTypes, 'TextonCompTypes', textonCompTypes, ...
    'SubsampledImagesPath', subsampledImagesPath, 'NbClusters', nbClusters, ...
    'ImagesPath', imagesPath);

% processResultsDatabaseFast(dbPath, 'image_004807', outputBasePath, dbFn, parallelized, randomized, ...
%     'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ObjectDb', objectDb, 'ObjectDbPath', objectDbPath, ...
%     'Types', types, 'CompTypes', compTypes, 'TextonTypes', textonTypes, 'TextonCompTypes', textonCompTypes, ...
%     'SubsampledImagesPath', subsampledImagesPath, 'NbClusters', nbClusters, ...
%     'ImagesPath', imagesPath);

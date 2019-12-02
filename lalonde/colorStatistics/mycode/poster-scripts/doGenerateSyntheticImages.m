%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doGenerateSyntheticImages
%   Generate images by pasting objects on top of similar objects
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doGenerateSyntheticImages(objectDb, topKeywords, topIndices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

% define the input and output paths
imagesBasePath = '/nfs/hn25/jlalonde/labelmeSubsampled/Images/';
rootPath = basePath;

databasesPath = fullfile(rootPath, 'databases');
objectDbPath = fullfile(rootPath, 'objectDb');
maskStackPath = fullfile(databasesPath, 'maskStacks');
outputBasePath = fullfile(rootPath, 'dataset', 'syntheticDb');

dbFn = @dbFnGenerateSyntheticImages;

% Size of the mask 
maskWidth = 128;

% Size of the resulting image
imageSize = 256;

%% Load object database and indices
if nargin == 0
    fprintf('Loading object database...\n');
    load(fullfile(databasesPath, 'objectDb.mat'));

    fprintf('Loading indices...\n');
    load(fullfile(databasesPath, 'keywordIndices.mat'));
end

%% Filter the objects based on their number of vertices (within a single keyword)

% Get the number of vertices for each object in the database
polygons = convertPolygonsFromXML(objectDb);
nbVertices = cellfun(@(x) size(x,1), polygons);

indicesToKeep = cell(1, length(topKeywords));
for i=1:length(topKeywords)
    indKeyword = topIndices{i};
    
    % only keep the objects which have enough vertices
    minNbVertices = prctile(nbVertices(indKeyword), 25);

    % modify the topIndices to keep only those objects
    indicesToKeep{i} = nbVertices(indKeyword) > minNbVertices;
    topIndices{i} = indKeyword(indicesToKeep{i});
end
    
%% Get the indices
% Reshape the database in the order corresponding to the indices
ind = [topIndices{:}];
objectDbReordered = objectDb(ind);

% Build a keyword for each object
keywords = {};
for i=1:length(topKeywords)
    t = repmat({topKeywords{i}}, 1, length(topIndices{i}));
    keywords = {keywords{:} t{:}};
end

%% Call the database function directly
parallelized = 0;
randomized = 1;
processDatabase(objectDbReordered(1425), outputBasePath, dbFn, parallelized, randomized, ...
    'document', 'image.filename', 'image.folder', ...
    'ImagesPath', imagesBasePath, 'MaskStackPath', maskStackPath, 'Keywords', keywords, ...
    'MaskWidth', maskWidth, 'ImageSize', imageSize, ...
    'DatabasePath', objectDbPath, 'Database', objectDbReordered, ...
    'NewIndices', ind, 'IndicesToKeep', indicesToKeep, 'TopKeywords', topKeywords);


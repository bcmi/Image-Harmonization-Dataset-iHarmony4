%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doGenerateRealImages
%   Generate images by selecting objects from real images
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doGenerateRealImages(objectDb, topKeywords, topIndices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

% define the input and output paths
imagesBasePath = '/nfs/hn21/projects/labelmeSubsampled/Images/';
rootPath = '/nfs/hn24/home/jlalonde/results/colorStatistics';

databasesPath = fullfile(rootPath, 'databases');
objectDbPath = fullfile(rootPath, 'objectDb');
outputBasePath = fullfile(rootPath, 'dataset', 'realDb');

dbFn = @dbFnGenerateRealImages;

% Size of the resulting image
imageSize = 256;

%% Load object database and indices
if nargin == 0
    fprintf('Loading object database...\n');
    load(fullfile(databasesPath, 'objectDb.mat'));

    fprintf('Loading indices...\n');
    load(fullfile(databasesPath, 'keywordIndices.mat'));
end

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
parallelized = 1;
randomized = 1;
processDatabase(objectDbReordered, outputBasePath, dbFn, parallelized, randomized, ...
    'document', 'filename', 'folder', ...
    'ImagesPath', imagesBasePath, 'Keywords', keywords, ...
    'ImageSize', imageSize, ...
    'DatabasePath', objectDbPath, 'Database', objectDbReordered, ...
    'NewIndices', ind);


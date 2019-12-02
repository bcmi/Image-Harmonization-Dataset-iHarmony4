%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeSignatures
%   Precompute the signatures for each image (object and background)
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeSignatures
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
% dbPath = fullfile(basePath, 'objectDb');
% imagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';

dbFn = @dbFnTmpMatching;

% for k-means
nbClusters = 100;

colorSpaces = {'lab'}; % otherwise it may be wayyy too slow!
% colorSpaces = {'lab', 'rgb', 'hsv', 'lalphabeta'};
% colorSpaces = {'lalphabeta'};

% call the database function
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', dbPath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ImagesPath', imagesPath, 'NbClusters', nbClusters);

%% Simply call the database function with several colorspaces
function r=dbFnTmpMatching(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('ColorSpaces', [], 'DbPath', [], 'ImagesPath', [], 'NbClusters', 0);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    r=dbFnPrecomputeSignatures(outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i}, 'DbPath', args.DbPath, ...
        'ImagesPath', args.ImagesPath, 'NbClusters', args.NbClusters);
end

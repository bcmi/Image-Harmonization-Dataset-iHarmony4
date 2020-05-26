%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingLocalTextonsColor
%   Evaluate the chi-square distance between the object and the
%   background's histograms, only on regions with similar texton distribution
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingLocalTextonsColor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';
basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
objectDbPath = fullfile(basePath, 'objectDb');
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');

outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingEvaluation';

dbFn = @dbFnTmpMatching;

colorSpaces = {'lab', 'lalphabeta'};
% colorSpaces = {'lab'};

% call the database function
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ImagesPath', imagesPath, ...
    'SubsampledImagesPath', subsampledImagesPath, 'ObjectDbPath', objectDbPath);

%% Simply call the database function with several colorspaces
function r=dbFnTmpMatching(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('ColorSpaces', [], 'DbPath', [], 'ImagesPath', [], ...
    'SubsampledImagesPath', [], 'ObjectDbPath', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    r=dbFnEvaluateMatchingLocalTextonsColor(outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i}, 'DbPath', args.DbPath, ...
        'ImagesPath', args.ImagesPath, 'SubsampledImagesPath', args.SubsampledImagesPath, ...
        'ObjectDbPath', args.ObjectDbPath);
end

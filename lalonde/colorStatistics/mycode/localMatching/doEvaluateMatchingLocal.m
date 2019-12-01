%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingBgBg
%   Evaluate the chi-square distance between the object and the
%   background's histograms
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingLocal 
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

colorSpaces = {'lab', 'rgb', 'hsv', 'lalphabeta'};

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
    r=dbFnEvaluateMatchingLocal(outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i}, 'DbPath', args.DbPath, ...
        'ImagesPath', args.ImagesPath, 'SubsampledImagesPath', args.SubsampledImagesPath, ...
        'ObjectDbPath', args.ObjectDbPath);
end

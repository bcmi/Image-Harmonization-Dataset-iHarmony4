%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingLocalSignatures
%   Evaluate the Earth Mover's distance between an object and its background as a measure of
%   realism.
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingLocalSignatures
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

outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingEvaluation';

dbFn = @dbFnTmpMatching;

% colorSpaces = {'lab', 'rgb', 'hsv', 'lalphabeta'};
colorSpaces = {'lab'};

% call the database function
parallelized = 0;
randomized = 0;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath, 'ImagesPath', imagesPath);

%% Simply call the database function with several colorspaces
function r=dbFnTmpMatching(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('ColorSpaces', [], 'DbPath', [], 'ImagesPath', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    r=dbFnEvaluateMatchingLocalSignatures(outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i}, 'DbPath', args.DbPath, 'ImagesPath', args.ImagesPath);
end

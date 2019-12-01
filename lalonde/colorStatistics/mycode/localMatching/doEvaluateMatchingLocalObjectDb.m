%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingLocalObjectDb
%   Evaluate the chi-square distance between the object and the
%   background's histograms
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doEvaluateMatchingLocalObjectDb
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
dbPath = fullfile(basePath, 'objectDb');

outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingEvaluationObjectDb';

dbFn = @dbFnTmpMatching;

% colorSpaces = {'lab', 'rgb', 'hsv', 'lalphabeta'};
colorSpaces = {'lab'};

% call the database function
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'DbPath', dbPath);

%% Simply call the database function with several colorspaces
function r=dbFnTmpMatching(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('ColorSpaces', [], 'DbPath', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    r=dbFnEvaluateMatchingLocalObjectDb(outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i}, 'DbPath', args.DbPath);
end

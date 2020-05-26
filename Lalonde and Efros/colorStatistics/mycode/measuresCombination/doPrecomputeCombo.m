%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeCombo
%   Evaluate the chi-square distance between the object and the
%   background's histograms, only on regions with similar texton distribution
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeCombo
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

dbFn = @dbFnTmp;

% thresholds to try
sigmasHistos = 0:0.05:1;
sigmasSignatures = 5:5:100;

% call the database function
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', dbPath, dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'ImagesPath', imagesPath, ...
    'SigmasHistos', sigmasHistos, 'SigmasSignatures', sigmasSignatures);

function r=dbFnTmp(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('DbPath', [], 'ImagesPath', [], 'SigmasHistos', [], 'SigmasSignatures', []);
args = parseargs(defaultArgs, varargin{:});

fprintf('Computing histograms...\n');
dbFnPrecomputeTextonsColorCombo(outputBasePath, annotation, ...
    'DbPath', args.DbPath, 'ImagesPath', args.ImagesPath, 'Sigmas', args.SigmasHistos);
fprintf('Computing signatures...\n');
dbFnPrecomputeSignaturesCombo(outputBasePath, annotation, ...
        'DbPath', args.DbPath, 'ImagesPath', args.ImagesPath, 'Sigmas', args.SigmasSignatures);
fprintf('done.\n');


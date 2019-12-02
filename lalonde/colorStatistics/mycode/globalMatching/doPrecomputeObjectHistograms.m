%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeObjectHistograms
%  Precompute the histogram of each object (with its corresponding background) 
%  necessary for the nearest neighbor matching
%   
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeObjectHistograms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
setPath;

% define the paths
baseDbPath = '/nfs/hn21/projects/labelmeSubsampled/';
imagesPath = fullfile(baseDbPath, 'Images');

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
objectDbPath = fullfile(basePath, 'objectDb');
indPath = fullfile(basePath, 'illuminationContext', 'concatHistograms');
outputBasePath = objectDbPath;

dbFn = @dbFnTmpMatching;

nbBins = 50;

colorSpaces = {'lab', 'lalphabeta'};

% call the database
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(objectDbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpaces', colorSpaces, 'ObjectDbPath', objectDbPath, 'ImagesPath', imagesPath, ...
    'NbBins', nbBins, 'IndPath', indPath);

%% Simply call the database function with several colorspaces
function r=dbFnTmpMatching(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('ColorSpaces', [], 'ImagesPath', [], 'NbBins', [], ...
    'SubsampledImagesPath', [], 'ObjectDbPath', [], 'IndPath', []);
args = parseargs(defaultArgs, varargin{:});

% load the active indices for lab histograms (to speed-up computations and reduce memory usage)
load(fullfile(args.IndPath, sprintf('indActiveLab_%d.mat', args.NbBins)));
load(fullfile(args.IndPath, sprintf('indActiveHsv_%d.mat', args.NbBins)));
load(fullfile(args.IndPath, sprintf('indActiveLalphabeta_%d.mat', args.NbBins)));

for i=1:length(args.ColorSpaces)
    if strcmp(args.ColorSpaces{i}, 'lab')
        activeInd = indActiveLab;
    elseif strcmp(args.ColorSpaces{i}, 'hsv')
        activeInd = indActiveHsv;
    elseif strcmp(args.ColorSpaces{i}, 'lalphabeta')
        activeInd = indActiveLalphabeta;
    end
    r=dbFnPrecomputeObjectHistograms(outputBasePath, annotation, ...
        'ColorSpace', args.ColorSpaces{i}, 'ObjectDbPath', args.ObjectDbPath, 'ImagesPath', args.ImagesPath, ...
        'NbBins', args.NbBins, 'ActiveInd', activeInd);
end


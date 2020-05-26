%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingHistoMarginals
%   Evaluates whether an image matches its expected color distributions
%   (1st and 2nd order). Based solely on histogram comparison.
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Evalu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';
addpath ../../3rd_party/parseArgs;

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

% histogram paths
histoPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesHistoMarginals/';
histoPath1stOrderMarginal = fullfile(histoPath, 'total1stMarginal.mat');
histoPath2ndOrderMarginal = fullfile(histoPath, 'total2ndMarginal.mat');
histoPath1stOrderPairwise = fullfile(histoPath, 'total1stPairwise.mat');
histoPath2ndOrderPairwise = fullfile(histoPath, 'total2ndPairwise.mat');

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';
colorSpaces{3} = 'hsv';

% load the histograms
load(histoPath1stOrderMarginal);
load(histoPath2ndOrderMarginal);
load(histoPath1stOrderPairwise);
load(histoPath2ndOrderPairwise);

dbFn = @dbFnTmpMatching;

% call the database function
processResultsDatabaseParallel(dbPath, outputBasePath, subDirs, dbFn, ...
    'Histo1stOrderMarginal', cumulative1stOrderMarginal, ...
    'Histo2ndOrderMarginal', cumulative2ndOrderMarginal, ...
    'Histo1stOrderPairwise', cumulative1stOrderPairwise, ...
    'Histo2ndOrderPairwise', cumulative2ndOrderPairwise, ...
    'ColorSpaces', colorSpaces);


%% Simply call the database function with several colorspaces
function dbFnTmpMatching(annotation, dbPath, outputBasePath, varargin)

defaultArgs = struct('ColorSpaces', [], ...
    'Histo1stOrderMarginal', [], ...
    'Histo2ndOrderMarginal', [], ...
    'Histo1stOrderPairwise', [], ...
    'Histo2ndOrderPairwise', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    dbFnEvaluateMatchingHistoMarginals(annotation, dbPath, outputBasePath, ...
        'ColorSpace', args.ColorSpaces{i}, ...
        'Histo1stOrderMarginal', args.Histo1stOrderMarginal, ...
        'Histo2ndOrderMarginal', args.Histo2ndOrderMarginal, ...
        'Histo1stOrderPairwise', args.Histo1stOrderPairwise, ...
        'Histo2ndOrderPairwise', args.Histo2ndOrderPairwise);
end


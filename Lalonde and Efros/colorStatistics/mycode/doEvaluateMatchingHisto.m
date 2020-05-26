%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doEvaluateMatchingHisto
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
function doEvaluateMatchingHisto 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';
addpath ../../3rd_party/parseArgs;

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataJoint/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/testDataJoint/';
subDirs = {'.'};

% histogram paths
histoPath = '/nfs/hn01/jlalonde/results/colorStatistics/smallDataset/occurencesSmallDataset/occurencesHisto/';
histoPath1stOrder = fullfile(histoPath, 'total1st.mat');
histoPath2ndOrder = fullfile(histoPath, 'total2nd.mat');

% load the histograms
total1stOrder = []; total2ndOrder = []; colorSpaces = [];
load(histoPath1stOrder);
load(histoPath2ndOrder);

dbFn = @dbFnTmpMatching;

% call the database function
processResultsDatabaseParallelFast(dbPath, outputBasePath, subDirs, dbFn, ...
    'Histo1stOrder', cumulative1stOrder, ...
    'Histo2ndOrder', cumulative2ndOrder, ...
    'ColorSpaces', colorSpaces);


%% Simply call the database function with several colorspaces
function dbFnTmpMatching(annotation, dbPath, outputBasePath, varargin)

defaultArgs = struct('ColorSpaces', [], 'Histo1stOrder', [], 'Histo2ndOrder', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    dbFnEvaluateMatchingHisto(annotation, dbPath, outputBasePath, ...
        'ColorSpace', args.ColorSpaces{i}, ...
        'Histo1stOrder', args.Histo1stOrder{i}, ...
        'Histo2ndOrder', args.Histo2ndOrder{i});
end



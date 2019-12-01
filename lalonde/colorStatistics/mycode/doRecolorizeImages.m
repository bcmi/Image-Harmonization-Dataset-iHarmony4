%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileMatchingResults
%   Scripts that re-colorizes images based on predicted color distributions
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doRecolorizeImages 
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
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/testDataRecolorized/';
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

% histogram paths
histoPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesHisto/';
histoPath1stOrder = fullfile(histoPath, 'total1st.mat');
histoPath2ndOrder = fullfile(histoPath, 'total2nd.mat');

% load the histograms
total1stOrder = []; total2ndOrder = []; 
load(histoPath1stOrder);
load(histoPath2ndOrder);

colorSpaces{1} = 'lab';
colorSpaces{2} = 'rgb';

nbColorsToGenerate = [10 100 500 1000];

dbFn = @dbFnTmpRecolorize;

% call the database function
processResultsDatabaseParallel(dbPath, outputBasePath, subDirs, dbFn, ...
    'Histo1stOrder', cumulative1stOrder, 'Histo2ndOrder', cumulative2ndOrder, ...
    'ColorSpaces', colorSpaces, 'NbColors', nbColorsToGenerate);


%% Simply call the database function with several colorspaces
function dbFnTmpRecolorize(annotation, dbPath, outputBasePath, varargin)

defaultArgs = struct('ColorSpaces', [], 'Histo1stOrder', [], 'Histo2ndOrder', [], ...
    'NbColors', []);
args = parseargs(defaultArgs, varargin{:});

for i=1:length(args.ColorSpaces)
    dbFnRecolorizeImages(annotation, dbPath, outputBasePath, ...
        'ColorSpace', args.ColorSpaces{i}, ...
        'Histo1stOrder', args.Histo1stOrder{i}, ...
        'Histo2ndOrder', args.Histo2ndOrder{i}, ...
        'NbColors', args.NbColors);
end



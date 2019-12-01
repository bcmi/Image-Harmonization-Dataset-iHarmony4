%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurencesTextonsSplit
%   Compiles the textons results obtained from the training data
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceTextonsSparseglobal cumulative1stOrder cumulative2ndOrder;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
outputDbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
dbFn = @dbFnCompileOccurence;
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

% initialize the cumulative co-occurences to empty
cumulative1stOrder = [];
cumulative2ndOrder = [];

% sparseness=0.1: choose only 10% of images for computing
N = 5;
sparseness = 1;

% call the database function
processResultsDatabase(dbPath, outputDbPath, subDirs, dbFn, 'Sparseness', sparseness, 'N', N);

% save the info for all the color spaces at the same time
save(fullfile(dbPath, sprintf('cumulativeTextons1stOrderSparse%dx%d_%d_unsorted.mat', N, N, sparseness*100)), 'cumulative1stOrder');
save(fullfile(dbPath, sprintf('cumulativeTextons2ndOrderSparse%dx%d_%d_unsorted.mat', N, N, sparseness*100)), 'cumulative2ndOrder');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCompileOccurence(annotation, dbPath, outputBasePath, varargin)
%   Accumulates co-occurence results.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnCompileOccurence(imgInfo, dbPath, outputBasePath, varargin)
global cumulative1stOrder cumulative2ndOrder;

addpath ../../3rd_party/parseArgs;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'Sparseness', 1, 'N', 1);
args = parseargs(defaultArgs, varargin{:});

if rand > args.Sparseness
    return;
end

tic;
fprintf('Compiling image %s...', imgInfo.image.filename);
% look if the information was computed
if isfield(imgInfo, sprintf('colorStatisticsTextons%dx%dUnsorted', args.N, args.N)) 
    
    % read the 1st order
    filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.(sprintf('colorStatisticsTextons%dx%dUnsorted', args.N, args.N)).firstOrder.file);
        
    % this will load the 1st order statistics
    textonHist1stOrder = [];
    load(filePath);
    textonHist1stOrder = single(full(textonHist1stOrder));

    if isempty(cumulative1stOrder)
        cumulative1stOrder = textonHist1stOrder;
    else
        cumulative1stOrder = cumulative1stOrder + textonHist1stOrder;
    end
    clear textonHist1stOrder;

    % read the 2nd order
    filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.(sprintf('colorStatisticsTextons%dx%dUnsorted', args.N, args.N)).secondOrder.file);

    % load the .mat file
    textonHist2ndOrder = [];
    load(filePath);
    textonHist2ndOrder = single(full(textonHist2ndOrder));

    if isempty(cumulative2ndOrder)
        cumulative2ndOrder = textonHist2ndOrder;
    else
        cumulative2ndOrder = cumulative2ndOrder + textonHist2ndOrder;
    end
    clear textonHist2ndOrder;
end
t = toc; fprintf('done in %.2f seconds!\n', t);
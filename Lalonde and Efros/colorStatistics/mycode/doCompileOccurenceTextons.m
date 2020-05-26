%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileOccurencesGMM
%   Compiles the textons results obtained from the training data
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileOccurenceTextonsglobal cumulative1stOrder cumulative2ndOrder;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
dbFn = @dbFnCompileOccurence;
subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

% initialize the cumulative co-occurences to empty
cumulative1stOrder = [];
cumulative2ndOrder = [];

% call the database function
processResultsDatabase(dbPath, dbPath, subDirs, dbFn);

% save the info for all the color spaces at the same time
save(fullfile(dbPath, 'cumulativeTextons1stOrder.mat'), 'cumulative1stOrder');
save(fullfile(dbPath, 'cumulativeTextons2ndOrder.mat'), 'cumulative2ndOrder');

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
defaultArgs = struct('Recompute', 1);
args = parseargs(defaultArgs, varargin{:});

fprintf('Compiling image %s...', imgInfo.image.filename);

% look if the information was computed
if isfield(imgInfo, 'colorStatisticsTextons') 
    
    % read the 1st order
    filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatisticsTextons.firstOrder.file);
        
    % this will load the 1st order statistics
    textonHist1stOrder = [];
    load(filePath);

    if isempty(cumulative1stOrder)
        cumulative1stOrder = textonHist1stOrder;
    else
        cumulative1stOrder = cumulative1stOrder + textonHist1stOrder;
    end

    % read the 2nd order
    filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatisticsTextons.secondOrder.file);

    % load the .mat file
    textonHist2ndOrder = [];
    load(filePath);

    if isempty(cumulative2ndOrder)
        cumulative2ndOrder = textonHist2ndOrder;
    else
        cumulative2ndOrder = cumulative2ndOrder + textonHist2ndOrder;
    end
end
fprintf('done!\n');

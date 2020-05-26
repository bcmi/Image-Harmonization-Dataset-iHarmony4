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
function doCompileOccurenceTextonsSplit(sClass)global cumulative1stOrder cumulative2ndOrder;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath '../database/';

sClass = str2double(sClass);
switch sClass
    case 1
        subClass = 'coast';
    case 2 
        subClass = 'forest';
    case 3
        subClass = 'highway';
    case 4
        subClass = 'insideCity';
    case 5
        subClass = 'mountain';
    case 6 
        subClass = 'openCountry';
    case 7
        subClass = 'street';
    case 8
        subClass = 'tallBuilding';
    otherwise
        error('Invalid option %d', sClass);
end


% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextonsTmp/spatial_envelope_256x256_static_8outdoorcategories/';
outputDbPath = '/nfs/hn01/jlalonde/results/colorStatistics/occurencesTextons/';
dbFn = @dbFnCompileOccurence;
subDirs = {subClass};

% initialize the cumulative co-occurences to empty
cumulative1stOrder = [];
cumulative2ndOrder = [];

% call the database function
processResultsDatabase(dbPath, outputDbPath, subDirs, dbFn);

% save the info for all the color spaces at the same time
save(fullfile(dbPath, sprintf('cumulativeTextons1stOrder_%s.mat', subClass)), 'cumulative1stOrder');
save(fullfile(dbPath, sprintf('cumulativeTextons2ndOrder_%s.mat', subClass)), 'cumulative2ndOrder');

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

tic;
fprintf('Compiling image %s...', imgInfo.image.filename);
% look if the information was computed
if isfield(imgInfo, 'colorStatisticsTextons') 
    
    % read the 1st order
    filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatisticsTextons.firstOrder.file);
        
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
    filePath = fullfile(outputBasePath, imgInfo.image.folder, imgInfo.colorStatisticsTextons.secondOrder.file);

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

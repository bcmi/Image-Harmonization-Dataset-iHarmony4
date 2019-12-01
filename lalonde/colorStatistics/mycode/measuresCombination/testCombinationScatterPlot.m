% function testCombinationScatterPlot

%% Setup paths and load databases
addpath ../;
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
outputBasePath = '/nfs/hn01/jlalonde/status/colorStatistics/';
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
databasesPath = fullfile(basePath, 'databases');

load(fullfile(compiledResultsPath, 'compiledResults.mat')); 
load(fullfile(compiledResultsPath, 'labelings.mat'));
load(fullfile(databasesPath, 'indicesTrainTest.mat'));

%% Get local scores
localMeasure = 'objBgDst';
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, localMeasure)); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
scoresLocal = scoresLocal ./ max(scoresLocal);

%% Get global scores
globalMeasure = 'jointObjColorTexton_threshold_50';
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, globalMeasure)); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

%% Balance dataset
indRealistic = indRealistic(1:round(length(indRealistic)/2));
indReal = indReal(1:round(length(indReal)/2));
indData = [indRealistic; indReal; indUnrealistic];

%% Visualize input space

% color-code according to class
colors = zeros(length(scoresGlobal), 3);
colors(indRealistic, :) = repmat([0 0 1], length(indRealistic), 1);
colors(indReal, :) = repmat([0 0 1], length(indReal), 1);
colors(indUnrealistic, :) = repmat([1 0 0], length(indUnrealistic), 1);

heights = ones(length(scoresGlobal), 1);
heights(indUnrealistic) = 0;

scatter3(scoresLocal(indData), scoresGlobal(indData), heights(indData), 50, colors(indData), 'filled');
title(sprintf('Global: %s vs Local: %s', strrep(globalMeasure, '_', '\_'), strrep(localMeasure, '_', '\_')));
xlabel('local'), ylabel('global');
xlim([0 1]), ylim([0 1]), zlim([0 1]);
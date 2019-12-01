%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doSplitDataIntoTrainingAndTesting
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doSplitDataIntoTrainingAndTesting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

databasesPath = fullfile(basePath, 'databases');
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');

% Version: with the user-provided labelings
labelingFile = 'userLabelings.mat';
outputFile = 'userIndicesTrainTest.mat';

% This contains labels isGenerated and imageLabel
load(fullfile(compiledResultsPath, labelingFile));
load(fullfile(databasesPath, 'randSeed.mat'));

fprintf('Make sure the script doCompileLabeling.m was previously run!\n');

%% Split the database into 2 groups: trainDb and testDb

% training data percentage
trainingDataPct = 0.5;

indRealistic = find(imageLabel == 1);
indReal = find(~isGenerated);
indRealistic = setdiff(indRealistic, indReal);
indUnrealistic = find(imageLabel == 2);

% set the random generator seed
% rand('state', randSeed);

% balance the indices
nbIndices = min(length(indRealistic), length(indUnrealistic));
% only keep as many real images as there are unrealistic/realistic images
indReal = indReal(randperm(length(indReal)));
indReal = indReal(1:round(nbIndices/2));
indRealistic = indRealistic(randperm(length(indRealistic)));
indRealistic = indRealistic(1:round(nbIndices/2));
indUnrealistic = indUnrealistic(randperm(length(indUnrealistic)));
indUnrealistic = indUnrealistic(1:nbIndices);

% split each indices group into two groups: training and testing
indRealRand = randperm(length(indReal));
indRealisticRand = randperm(length(indRealistic));
indUnrealisticRand = randperm(length(indUnrealistic));

indRealisticTrain = indRealistic(indRealisticRand(1:round(length(indRealistic).*trainingDataPct))); %#ok
indRealTrain = indReal(indRealRand(1:round(length(indReal).*trainingDataPct))); %#ok
indUnrealisticTrain = indUnrealistic(indUnrealisticRand(1:round(length(indUnrealistic).*trainingDataPct))); %#ok

indRealisticTest = indRealistic(indRealisticRand(round(length(indRealistic).*trainingDataPct)+1:end)); %#ok 
indRealTest = indReal(indRealRand(round(length(indReal).*trainingDataPct)+1:end)); %#ok
indUnrealisticTest = indUnrealistic(indUnrealisticRand(round(length(indUnrealistic).*trainingDataPct)+1:end)); %#ok

indRealistic = [indRealisticTrain; indRealisticTest]; %#ok
indReal = [indRealTrain; indRealTest]; %#ok
indUnrealistic = [indUnrealisticTrain; indUnrealisticTest]; %#ok

%% Save the results
save(fullfile(databasesPath, outputFile), 'indRealisticTrain', 'indRealTrain', 'indUnrealisticTrain', ...
    'indRealisticTest', 'indRealTest', 'indUnrealisticTest', 'indRealistic', 'indReal', 'indUnrealistic');
fprintf('done.\n');
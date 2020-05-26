% function testCombinationCrossValidation

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
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
scoresLocal = scoresLocal ./ max(scoresLocal);

%% Get global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_50')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

K = 20;
trainingScores = zeros(K, 1);
trainingThresholds = zeros(K, 1);
testScores = zeros(K, 1);
for k=1:K
    divRealistic = floor(length(indRealistic) / K);
    divReal = floor(length(indReal) / K);
    divUnrealistic = floor(length(indUnrealistic) / K);
    
    indRealisticTest = (k-1)*divRealistic+1:min(k*divRealistic, length(indRealistic));
    indRealTest = (k-1)*divReal+1:min(k*divReal, length(indReal));
    indUnrealisticTest = (k-1)*divUnrealistic+1:min(k*divUnrealistic, length(indUnrealistic));
    
    indRealisticTrain = setdiff((1:length(indRealistic)), indRealisticTest);
    indRealTrain = setdiff((1:length(indReal)), indRealTest);
    indUnrealisticTrain = setdiff((1:length(indUnrealistic)), indUnrealisticTest);
    
    % Get ROC scores with the training data
    [trainingThresholds(k), trainingScores(k)] = getBestGlobalThreshold(scoresGlobal, scoresLocal, indRealistic(indRealisticTrain), indReal(indRealTrain), indUnrealistic(indUnrealisticTrain));

    % Test on test data
    scores = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, bestThreshold);
    testScores(k) = getROCScoreFromScores(scores, indRealistic(indRealisticTest), indReal(indRealTest), indUnrealistic(indUnrealisticTest));
end


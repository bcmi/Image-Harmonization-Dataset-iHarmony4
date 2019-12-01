%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function findBestCombination
%   
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function findBestCombination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths and load databases
addpath ../;
setPath;

% basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
databasesPath = fullfile(basePath, 'databases');

load(fullfile(compiledResultsPath, 'compiledResults.mat')); 
% load(fullfile(compiledResultsPath, 'labelings.mat'));
% load(fullfile(databasesPath, 'indicesTrainTest.mat'));
load(fullfile(compiledResultsPath, 'userLabelings.mat'));
load(fullfile(databasesPath, 'userIndicesTrainTest.mat'));

% localMethods = {'objBgDst', 'objBgDstW', 'objBgDstWS', 'objBgDstTextonW'};
localMethods = {'objBgDst', 'objBgDstTextonColorW'};

globalMethods = {'jointObj_75', 'jointObj_50', 'jointObj_25', ...
    'jointObj_threshold', 'jointBg_threshold', ...
    'jointObjColorTexton_threshold_0', 'jointObjColorTexton_threshold_25', 'jointObjColorTexton_threshold_50', 'jointObjColorTexton_threshold_75', 'jointObjColorTexton_threshold_100', ...
    };
    %     'jointBgColorTexton_threshold_0', 'jointBgColorTexton_threshold_25', 'jointBgColorTexton_threshold_50', 'jointBgColorTexton_threshold_75', 'jointBgColorTexton_threshold_100', ...
%     'jointObjColorTextonSingle_threshold_0', 'jointObjColorTextonSingle_threshold_25', 'jointObjColorTextonSingle_threshold_50', 'jointObjColorTextonSingle_threshold_75', 'jointObjColorTextonSingle_threshold_100', ...
%     'jointBgColorTextonSingle_threshold_0', 'jointBgColorTextonSingle_threshold_25', 'jointBgColorTextonSingle_threshold_50', 'jointBgColorTextonSingle_threshold_75', 'jointBgColorTextonSingle_threshold_100'};
colorSpace = 'lab';
dist = 'distChi';

scoresIndivLocal = zeros(1, length(localMethods));
scoresIndivGlobal = zeros(1, length(globalMethods));

%% Loop over all possible pairs
scores = zeros(length(localMethods), length(globalMethods));
thresholds = zeros(length(localMethods), length(globalMethods));

for localInd = 1:length(localMethods)
    c = find(strcmp(colorSpaces, colorSpace)); %#ok
    t = find(strcmp(techniques, localMethods{localInd})); %#ok
    dt = find(strcmp(distances, dist)); %#ok
    ei = find(strcmp(evalName, 'localEval')); %#ok

    scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
    scoresIndivLocal(localInd) = getROCScoreFromScores(scoresLocal, indRealistic, indReal, indUnrealistic);
    
    for globalInd = 1:length(globalMethods)
        c = find(strcmp(colorSpaces, colorSpace)); %#ok
        t = find(strcmp(techniques, globalMethods{globalInd})); %#ok
        dt = find(strcmp(distances, dist)); %#ok
        ei = find(strcmp(evalName, 'globalEval')); %#ok

        scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

        fprintf('Evaluating %s vs %s...', localMethods{localInd}, globalMethods{globalInd});
        
        [thresholds(localInd, globalInd), scores(localInd, globalInd)] = getBestGlobalThreshold(scoresGlobal, scoresLocal, indRealistic, indReal, indUnrealistic);
        
        fprintf('done.\n');
    end
end

% compute the individual scores
for globalInd = 1:length(globalMethods)
    c = find(strcmp(colorSpaces, colorSpace)); %#ok
    t = find(strcmp(techniques, globalMethods{globalInd})); %#ok
    dt = find(strcmp(distances, dist)); %#ok
    ei = find(strcmp(evalName, 'globalEval')); %#ok

    scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
    scoresIndivGlobal(globalInd) = getROCScoreFromScores(scoresGlobal, indRealistic, indReal, indUnrealistic);
end

%% Find the maximum
maxInd = argmax(scores);
[r,c] = ind2sub(size(scores), maxInd);

bestThreshold = thresholds(r,c);
bestScore = scores(r,c);

% Print best combination
fprintf('\n**COMBINATION SUMMARY**\n');
fprintf('Best combination is : %s with %s, t=%.3f with score of %.4f\n', localMethods{r}, globalMethods{c}, bestThreshold, bestScore);


%% Also print scores for all techniques individually
fprintf('\n**LOCAL SCORES SUMMARY**\n');
for i=1:length(localMethods)
    fprintf('\t%s: %.4f\n', localMethods{i}, scoresIndivLocal(i));
end

fprintf('\n**GLOBAL SCORES SUMMARY**\n');
for i=1:length(globalMethods)
    fprintf('\t%s: %.4f\n', globalMethods{i}, scoresIndivGlobal(i));
end
    
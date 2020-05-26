% function testCombination

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
t = find(strcmp(techniques, 'jointBgColorTexton_threshold_50')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

%% Get ROC scores with the training data
tInc = 0:0.025:1;

% indRealistic = sort(indRealistic);
% indReal = sort(indReal);
% indUnrealistic = sort(indUnrealistic);

scores = zeros(1, length(scoresGlobal));
rocScoresTrain = zeros(length(tInc), 1);
rocScoresTest = zeros(length(tInc), 1);
for t=tInc
%     scores(scoresLocal<=t) = 0; 
%     scores(scoresLocal<0) = scoresGlobal(scoresLocal<0); % if scoresLocal == -1, then the local score cannot tell anything
%     scores(scoresLocal>t) = scoresGlobal(scoresLocal>t);
    
    scores(scoresGlobal<=t) = 0;
    scores(scoresGlobal>t) = scoresLocal(scoresGlobal>t);
    scores(scoresLocal<0) = scoresGlobal(scoresLocal<0);
    
    rocScoresTrain(tInc==t) = getROCScoreFromScores(scores, indRealistic(1:round(length(indRealistic)/2)), indReal(1:round(length(indReal)/2)), indUnrealistic);
%     rocScoresTrain(tInc==t) = getROCScoreFromScores(scores, [], indReal, indUnrealistic);
    rocScoresTest(tInc==t) = getROCScoreFromScores(scores, indRealisticTest(1:round(length(indRealisticTest)/2)), indRealTest(1:round(length(indRealTest)/2)), indUnrealisticTest);
%     rocScoresTest(tInc==t) = getROCScoreFromScores(scores, [], indRealTest, indUnrealisticTest);  
end

indMax = argmax(rocScoresTrain);

%% Plot the results
figure(4); hold on;
plot(tInc, rocScoresTrain, 'b', 'LineWidth', 2);
plot(tInc, rocScoresTest, 'r', 'LineWidth', 2);
plot(tInc(indMax), rocScoresTrain(indMax), '.b', 'MarkerSize', 40);
xlabel('threshold'), ylabel('ROC score');
legend('train', 'test');
title(sprintf('ROC scores for varying thresholds on local score. Best=%.4f (%.4f), Initial=%.4f', rocScoresTrain(indMax), tInc(indMax), rocScoresTrain(1)));

% Visualize input space
% figure(5); hold on;
% plot(scoresGlobalEq(indUnrealisticTrain), scoresLocal(indUnrealisticTrain), '.b');
% plot(scoresGlobalEq(indRealisticTrain), scoresLocal(indRealisticTrain), '.r');



        
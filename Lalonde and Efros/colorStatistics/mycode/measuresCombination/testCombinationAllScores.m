% function testCombinationAllScores

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

scores = cell(4, 1);

%% Get Reinhard scores
c = find(strcmp(colorSpaces, 'lalphabeta')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresReinhard = mysqueeze(scores1stOrder(ei, c, :, t, dt)); %#ok
scores{1} = scoresReinhard;
names{1} = 'Reinhard';

%% Get best local score

c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
scores{2} = scoresLocal;
names{2} = 'Best local';

%% Get best global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_50')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
scores{3} = scoresGlobal;
names{3} = 'Best global';

%% Get best combination of global and local scores
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_75')); %#ok
scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

thresholdGlobal = 0.35;
scores{4} = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, thresholdGlobal);
names{4} = 'Combination';

%% Compute the ROC curves for each score
area = zeros(length(scores), 1);
tp = cell(length(scores), 1);
fp = cell(length(scores), 1);
for i=1:length(scores)
    [area(i), tp{i}, fp{i}] = getROCScoreFromScores(scores{i}, indRealistic, indReal, indUnrealistic);
    names{i} = sprintf('%s (%.2f)', names{i}, area(i));
end

[s, ind] = sort(area);

colors = jet(length(scores));
figure(1), hold on;
for i=ind(:)'
    plot(tp{i}, fp{i}, 'LineWidth', 2, 'Color', colors(i,:));
end
legend(names{ind});

title('ROC curve comparison, overview');

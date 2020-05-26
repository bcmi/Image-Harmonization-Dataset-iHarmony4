% function generateROCCurveFinal

%% Setup paths and load databases
addpath /nfs/hn01/jlalonde/code/matlab/trunk/mycode/colorStatistics;
setPath;

% basePath = '/nfs/hn01/jlalonde/results/colorStatistics/iccv07';
outputBasePath = '/nfs/hn01/jlalonde/status/colorStatistics/';
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
names{1} = 'Baseline';

%% Get best local score

c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
scores{2} = scoresLocal;
names{2} = 'Local approach';

%% Get best global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_50')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok
scores{3} = scoresGlobal;
names{3} = 'Global approach';

%% Get best combination of global and local scores
thresholdGlobal = 0.35;

%% Get best global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_75')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobalCombo = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

scores{4} = combineLocalAndGlobalScores(scoresLocal, scoresGlobalCombo, thresholdGlobal);
names{4} = 'Combination';


%% Compute the ROC curves for each score
area = zeros(length(scores), 1);
tp = cell(length(scores), 1);
fp = cell(length(scores), 1);
for i=1:length(scores)
    [area(i), tp{i}, fp{i}] = getROCScoreFromScores(scores{i}, indRealistic, indReal, indUnrealistic);
    names{i} = sprintf('%s (%.2f)', names{i}, area(i));
end

[s, ind] = sort(area, 'descend');

fontSize = 14;
% colors = lines(length(scores));
colors = [0 0 0; 1 0 0; 0 1 0; 0 0 1];

figure(1), hold on;
for i=ind(:)'
    if i==1
        plot(tp{i}, fp{i}, '--', 'LineWidth', 3, 'Color', colors(i,:));
    else
        plot(tp{i}, fp{i}, 'LineWidth', 3, 'Color', colors(i,:));
    end
end
plot(tp{4}, fp{4}, 'LineWidth', 3, 'Color', colors(4,:));
legend(names{ind}, 'Location', 'SouthEast');

title('ROC curve comparison', 'FontSize', fontSize+6);
xlabel('False Positive Rate', 'FontSize', fontSize), ylabel('True Positive Rate', 'FontSize', fontSize);
set(gca, 'FontSize', fontSize);

% saveas(gcf, 'summaryROC.eps', 'psc2');
% saveas(gcf, 'summaryROC.pdf');
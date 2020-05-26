% function testCombination

%%
addpath ../;
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
outputBasePath = '/nfs/hn01/jlalonde/status/colorStatistics/';
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');

load ~/nfs/results/colorStatistics/databases/matchingEvaluationDb.mat;
load ~/nfs/results/colorStatistics/databases/syntheticDb.mat;

load(fullfile(compiledResultsPath, 'compiledResults.mat')); 
load(fullfile(compiledResultsPath, 'labelings.mat'));

%% Get the indices of 1000 real images
realInd = find(arrayfun(@(x) ~str2double(x.document.image.generated), syntheticDb));
N = 1000;
randInd = randperm(length(realInd));
realInd = realInd(randInd(1:N));
save('realInd.mat',  'realInd');
load('realInd.mat');

%% Try local method

c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = squeeze(scores2ndOrder(ei, c, realInd, t, dt)); %#ok
figure(1), hist(scoresLocal, 100), title('Distribution of local scores');

%% Get global method

c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_50')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = squeeze(scores2ndOrder(ei, c, realInd, t, dt)); %#ok
figure(2), hist(scoresGlobal, 100), title('Distribution of global scores');

%% Try thresholds and plot global histograms

figure(3);
tInc = (0:0.1:0.9) .* prctile(scoresLocal, 90);
% tInc = (0.5:0.05:0.95) .* prctile(scoresLocal, 90);
for t=tInc
    scores = scoresGlobal(scoresLocal>t);
    
    % find the indices of images which have scores higher than threshold
    subplot(2,5,find(t==tInc)), hist(scores, 25);
    title(sprintf('Mean: %f, median: %f', mean(scores), median(scores)));
end

        
% function testCombinationThreshold

%% Setup paths and load databases
addpath ../;
setPath;

basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
outputBasePath = '/nfs/hn01/jlalonde/status/colorStatistics';
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
measuresCombinationPath = fullfile(basePath, 'measuresCombination');
databasesPath = fullfile(basePath, 'databases');

load(fullfile(compiledResultsPath, 'compiledResults.mat')); 
load(fullfile(compiledResultsPath, 'labelings.mat'));
load(fullfile(databasesPath, 'indicesTrainTest.mat'));
load(fullfile(measuresCombinationPath, 'concatData.mat'));

% thresholds to try
sigmasHistos = 0:0.05:1;
sigmasSignatures = 5:5:100;

%% Get global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointBg_threshold')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = squeeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

% scale the scores in the [0,1] interval
scoresGlobal = scoresGlobal ./ prctile(scoresGlobal, 99);
scoresGlobal(scoresGlobal > 1) = 1;

thresholdsGlobal = 0:0.01:1;
nbThresholdsGlobal = length(thresholdsGlobal);

%% Histogram-based techniques
[nbTechniques, nbImages, nbThresholds] = size(accHistOverlapW);

% fixed min area threshold
% areaThreshold = 0.25;
areaThreshold = 0.5;
rocScoresHistos = zeros(nbTechniques, nbThresholds);
classifErrorHistos = zeros(nbTechniques, nbThresholds, nbThresholdsGlobal);
for techInd=1:nbTechniques
    for threshInd = 1:nbThresholds
        scores = zeros(nbImages, 1);
        indValid = (accHistOverlapW(techInd, :, threshInd) > areaThreshold);
        scoresLocal = accHistDistChi(techInd, :, threshInd);
        
        % equalize the scores according to the global scores
%         scoresLocal = histeq(scoresLocal, hist(scoresGlobal, 100));
        
        scores(indValid) = 1; % scoresLocal(indValid);
        scores(~indValid) = scoresGlobal(~indValid);

        classifErrorHistos(techInd, threshInd, :) = getClassificationErrorFromScores(thresholdsGlobal, scores, indValid, indRealistic, indReal, indUnrealistic);
        rocScoresHistos(techInd, threshInd) = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic);
    end
end

%% Plot results for histograms
% Try the mesh
[x,y] = meshgrid(thresholdsGlobal(:), sigmasHistos(:));
classifError = mysqueeze(classifErrorHistos(3, :, :));
figure(3); meshc(x, y, classifError);
xlabel('global'), ylabel('local'), zlabel('Classification error (%)');
hold on;
% plot the minimum
[r,c] = ind2sub(size(classifError), argmin(classifError));
localScore = sigmasHistos(r); 
plot3(thresholdsGlobal(c), sigmasHistos(r), classifError(argmin(classifError)), '.r', 'MarkerSize', 40);
title(sprintf('Histograms, globalT=%.2f, localT=%.2f, minError=%.2f', thresholdsGlobal(c), sigmasHistos(r), classifError(argmin(classifError))));

% Plot the curves with legend
figure(1), plot(repmat(sigmasHistos, 3, 1)', rocScoresHistos', 'LineWidth', 2);
legend('\alpha=0', '\alpha=0.33', '\alpha=0.66');
xlabel('local threshold'), ylabel('ROC score');
title(sprintf('Histograms technique, area threshold = %.2f', areaThreshold));

%% Plot ROC curve with histogram scores based on the local score found
tp = cell(nbTechniques, 1);
fp = cell(nbTechniques, 1);
areas = cell(nbTechniques, 1);
for techInd=1:nbTechniques
    threshInd = find(sigmasHistos==localScore);
    
    scores = zeros(nbImages, 1);
    indValid = (accHistOverlapW(techInd, :, threshInd) > areaThreshold);

    scores(indValid) = 1;% scoresLocal(indValid);
    scores(~indValid) = scoresGlobal(~indValid);

    [area, tp{techInd}, fp{techInd}] = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic);
    areas{techInd} = num2str(area);
end

cmap = jet(length(tp));
figure(10); hold on;
for i=1:length(tp)
    plot(tp{i}, fp{i}, 'LineWidth', 3, 'Color', cmap(i,:)), xlabel('false positive rate'), ylabel('true positive rate');
end

legend(areas{:});

return;

%% Signature-based technique
[nbTechniques, nbImages, nbThresholds] = size(accSignaturesPctDistW);

% fixed threshold on % of colors which are influenced by others
pctDistWThreshold = 0.95;
pctDistThreshold = 0.05;
rocScoresSignatures = zeros(nbTechniques, nbThresholds);
classifErrorSignatures = zeros(nbTechniques, nbThresholds, nbThresholdsGlobal);
for techInd=1:nbTechniques
    for threshInd = 1:nbThresholds
        scores = zeros(nbImages, 1);
        indValid = (accSignaturesPctDistW(techInd, :, threshInd) > pctDistWThreshold);
%         indValid = (accSignaturesPctDist(techInd, :, threshInd) > pctDistThreshold);
        scoresLocal = accSignaturesMeanClusterShifts(techInd, :, threshInd);
        
        % re-scale the scores in the [0,1] interval
        scoresLocal = scoresLocal ./ prctile(scoresLocal, 99);
        scoresLocal(scoresLocal > 1) = 1;
        
        % equalize the scores according to the global scores
        scoresLocal = histeq(scoresLocal, hist(scoresGlobal, 10));
        
        scores(indValid) = scoresLocal(indValid);
        scores(~indValid) = scoresGlobal(~indValid);
        
        scores(~indValid) = scoresGlobal(~indValid);
        classifErrorSignatures(techInd, threshInd, :) = getClassificationErrorFromScores(thresholdsGlobal, scores, indValid, indRealistic, indReal, indUnrealistic);
 
        rocScoresSignatures(techInd, threshInd) = getROCScoreFromScores(scores, indRealistic, indReal, indUnrealistic);
    end
end

%% Plot results for signatures
% Try the mesh
[x,y] = meshgrid(thresholdsGlobal(:), sigmasSignatures(:));
classifError = mysqueeze(classifErrorSignatures(1, :, :));
figure(4); meshc(x, y, classifError);
xlabel('global'), ylabel('local'), zlabel('Classification error (%)');
hold on;
% plot the minimum
[r,c] = ind2sub(size(classifError), argmin(classifError));
plot3(thresholdsGlobal(c), sigmasSignatures(r), classifError(argmin(classifError)), '.r', 'MarkerSize', 40);
title(sprintf('Signatures, globalT=%.2f, localT=%.2f, minError=%.2f', thresholdsGlobal(c), sigmasSignatures(r), classifError(argmin(classifError))));

% Plot the curves with legend
figure(2), plot(repmat(sigmasSignatures, 2, 1)', rocScoresSignatures', 'LineWidth', 2);
legend('no texture', 'with texture');
xlabel('threshold'), ylabel('ROC score');
title(sprintf('Signatures technique, threshold = %.2f', pctDistWThreshold)); 



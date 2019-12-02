%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function testPlotFeatures
%   Scripts that plots features and see if there's any separation between
%   classes (generated and originals)
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function testPlotFeatures 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% warning('KDE will fail with balaton');
%% Setup paths
addpath ../database;
addpath ../../3rd_party/vgg_matlab/vgg_image;
addpath ../../3rd_party/kde;

% Do we want to save the results?
doSave = 1;

% define the input and output paths
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/';
testDataPath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/';
imagesPath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/';
outputPath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/montageImages/';
dbFn = @dbFnCompileMatching;

subDirs = {'spatial_envelope_256x256_static_8outdoorcategories'};

% initialize the cumulative variables to empty
colorSpaces{1} = 'lab';
% colorSpaces{2} = 'rgb';
% colorSpaces{3} = 'hsv';

% different distances
distances{1} = 'chisq';
distances{2} = 'dot';

techniques = [];
% techniques = [techniques {'histo'}];
% techniques = [techniques {'textons'}];
% techniques = [techniques {'marginals'}];
techniques = [techniques {'pairwise'}];
% techniques{3} = 'nn';

%% Load the database
fprintf('Loading matching results database...');
% D = loadDatabase(dbPath, subDirs);
% save /nfs/hn01/jlalonde/results/colorStatistics/matchingResults/matchingResults.mat D;
load('/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/matchingResults.mat');

fprintf('Loading test data...');
% testData = loadDatabase(testDataPath, subDirs);
% save /nfs/hn01/jlalonde/results/colorStatistics/testData/testData.mat testData;
load('/nfs/hn01/jlalonde/results/colorStatistics/testData/testData.mat');
fprintf('done!\n');

% limit the size of D
% nbImages = 3500;
nbImages = length(D);

scores1stOrder = zeros(length(colorSpaces), nbImages, length(techniques), length(distances));
scores2ndOrder = zeros(length(colorSpaces), nbImages, length(techniques), length(distances));

scores1stOrderMarginals = zeros(length(colorSpaces), nbImages, 3);
scores2ndOrderMarginals = zeros(length(colorSpaces), nbImages, 3);

isGenerated = zeros(nbImages, 1);

%% Store all the scores, for each images
for j=1:nbImages
    isGenerated(j) = sscanf(D(j).document.image.generated, '%d');
    for i=1:length(colorSpaces)
        for k=1:length(techniques)
            for d=1:length(distances)
                dist1st = 0;
                dist2nd = 0;
                if strcmp(techniques{k}, 'histo') && (strcmp(colorSpaces{k}, 'lab') || strcmp(colorSpaces{k}, 'hsv'))
                    if strcmp(distances{d}, 'chisq')
                        dist1st = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHisto.firstOrder.distChi, '%f');
                        dist2nd = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHisto.secondOrder.distChi, '%f');
                    elseif strcmp(distances{d}, 'dot')
                        dist1st = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHisto.firstOrder.distDot, '%f');
                        dist2nd = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHisto.secondOrder.distDot, '%f');
                    end

                elseif strcmp(techniques{k}, 'textons') && strcmp(colorSpaces{i}, 'lab')
                    if strcmp(distances{d}, 'chisq')
                        dist1st = sscanf(D(j).document.colorStatistics(i).matchingEvaluationTextons.firstOrder.distChi, '%f');
                        dist2nd = sscanf(D(j).document.colorStatistics(i).matchingEvaluationTextons.secondOrder.distChi, '%f');
                    elseif strcmp(distances{d}, 'dot')
                        dist1st = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHisto.firstOrder.distDot, '%f');
                        dist2nd = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHisto.secondOrder.distDot, '%f');
                    end
                elseif strcmp(techniques{k}, 'nn')
                    t = sscanf(D(j).document.colorStatistics(i).matchingEvaluationNN.firstOrder.distChi, '%f');
                    dist = t(1); % just keep the first
                    % there's no second-order evaluation for nearest-neighbor
                elseif strcmp(techniques{k}, 'marginals')
                    if strcmp(distances{d}, 'chisq')
%                         for t=1:3
%                             scores1stOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.firstOrder(t).marginal.distChi, '%f');
%                             scores2ndOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.secondOrder(t).marginal.distChi, '%f');
%                         end
                    elseif strcmp(distances{d}, 'dot')
                        for t=1:3
%                             scores1stOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.firstOrder(t).marginal.distDot, '%f');
%                             scores2ndOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.secondOrder(t).marginal.distDot, '%f');
                        end
                    end
                elseif strcmp(techniques{k}, 'pairwise')
                    if strcmp(distances{d}, 'chisq')
                        for t=1:3
                            scores1stOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.firstOrder(t).pairwise.distChi, '%f');
                            scores2ndOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.secondOrder(t).pairwise.distChi, '%f');
                        end
                    elseif strcmp(distances{d}, 'dot')
                        for t=1:3
%                             scores1stOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.firstOrder(t).pairwise.distDot, '%f');
%                             scores2ndOrderMarginals(i, j, t) = sscanf(D(j).document.colorStatistics(i).matchingEvaluationHistoMarginal.secondOrder(t).pairwise.distDot, '%f');
                        end
                    end
                end
                scores1stOrder(i,j,k,d) = dist1st;
                scores2ndOrder(i,j,k,d) = dist2nd;
            end
        end
    end
end
fprintf('\n');

figure;
plot3(scores1stOrderMarginals(1, logical(isGenerated), 1), scores1stOrderMarginals(1, logical(isGenerated), 2), scores1stOrderMarginals(1, logical(isGenerated), 3), 'ob')
hold on;
plot3(scores1stOrderMarginals(1, logical(~isGenerated), 1), scores1stOrderMarginals(1, logical(~isGenerated), 2), scores1stOrderMarginals(1, logical(~isGenerated), 3), 'sr')
title('1st-order');

figure;
plot3(scores2ndOrderMarginals(1, logical(isGenerated), 1), scores2ndOrderMarginals(1, logical(isGenerated), 2), scores2ndOrderMarginals(1, logical(isGenerated), 3), 'ob')
hold on;
plot3(scores2ndOrderMarginals(1, logical(~isGenerated), 1), scores2ndOrderMarginals(1, logical(~isGenerated), 2), scores2ndOrderMarginals(1, logical(~isGenerated), 3), 'sr')
title('2nd-order');



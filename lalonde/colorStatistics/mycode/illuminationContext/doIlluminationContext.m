function doIlluminationContext 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
setPath;

% define the paths
% imagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images/';
% dbPath = '/nfs/hn21/projects/labelmeSubsampled/Annotation/';
imagesPath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDb/Images';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDb/Annotation';

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
% outputBasePath = fullfile(basePath, 'imageDb');
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDbPopup';
popupBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDbPopup';
dbFn = @dbFnIlluminationContext;

% load the active indices
nbBins = 50;
load(fullfile(basePath, 'illuminationContext', 'concatHistograms', sprintf('indActiveLab_%d.mat', nbBins)));
load(fullfile(basePath, 'illuminationContext', 'concatHistograms', sprintf('indActiveLalphabeta_%d.mat', nbBins)));


% call the database
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
    'PopupDir', popupBasePath, 'ImagesPath', imagesPath, 'Recompute', 1, 'NbBins', nbBins, ...
    'IndActiveLab', indActiveLab, 'IndActiveLalphabeta', indActiveLalphabeta);


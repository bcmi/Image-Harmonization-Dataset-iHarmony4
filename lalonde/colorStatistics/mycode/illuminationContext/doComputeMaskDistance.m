function doComputeMaskDistance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath ../;
setPath;

% define the paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
dbBasePath = fullfile(basePath, 'dataset', 'combinedDb');
dbPath = fullfile(dbBasePath, 'Annotation');

popupDbPath = fullfile(basePath, 'dataset', 'combinedDbPopup');
outputBasePath = fullfile(basePath, 'illuminationContext', 'distancesMasks');
concatMasksPath = fullfile(basePath, 'illuminationContext', 'concatMasks');

dbFn = @dbFnComputeMaskDistance;

types = {'sky', 'ground', 'vertical'};

for t=1:3
    type = types{t};
    fprintf('Processing for type %s...\n', type);
    % Loop over all the color spaces
    maskFile = fullfile(concatMasksPath, sprintf('concatMasks_%s.mat', type));

    fprintf('Loading %s...', maskFile);
    load(maskFile);
    fprintf('done.\n');

    outputPath = fullfile(outputBasePath, sprintf('%s', type));
    [m,m,m] = mkdir(outputPath); %#ok

    % call the database
    parallelized = 1;
    randomized = 1;
    processResultsDatabaseFast(dbPath, '', outputPath, dbFn, parallelized, randomized, ...
        'AccMasks', globAccMasks, 'Type', type, 'PopupDbPath', popupDbPath);
end
function doComputeIlluminationDistance
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
imagesPath = fullfile(dbBasePath, 'Images');
dbPath = fullfile(dbBasePath, 'Annotation');

popupDbPath = fullfile(basePath, 'dataset', 'combinedDbPopup');
outputBasePath = fullfile(basePath, 'illuminationContext', 'distances');
concatHistogramsPath = fullfile(basePath, 'illuminationContext', 'concatHistograms');

dbFn = @dbFnComputeIlluminationDistance;

nbBins = 50;

types = {'sky', 'ground', 'vertical'};
colorIndex = {'lab', 'hsv', 'rgb', 'lalphabeta'};

for t=1:3
    type = types{t};
    fprintf('Processing for type %s...\n', type);
    % Loop over all the color spaces
    for i=1:4
        histoFile = fullfile(concatHistogramsPath, sprintf('concatHisto_%s_%s.mat', type, colorIndex{i}));
        fprintf('Loading %s...', histoFile);
        load(histoFile);
        fprintf('done.\n');

        outputPath = fullfile(outputBasePath, sprintf('%s_%s', type, colorIndex{i}));
        [m,m,m] = mkdir(outputPath); %#ok

        % call the database
        parallelized = 1;
        randomized = 1;
        processResultsDatabaseFast(dbPath, '', outputPath, dbFn, parallelized, randomized, ...
            'AccHistoJoint', globAccHistoJoint, 'AccHistoMarginals', globAccHistoMarginals, ...
            'Type', type, 'ColorIndex', i, 'NbBins', nbBins, 'ImagesPath', imagesPath, ...
            'PopupDbPath', popupDbPath);
    end
end
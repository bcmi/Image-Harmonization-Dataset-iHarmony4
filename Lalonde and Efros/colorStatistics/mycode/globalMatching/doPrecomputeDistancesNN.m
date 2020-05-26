%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doPrecomputeDistancesNN
%   Pre-compute the distances from each image in the synthetic dataset to every other image
%   in the database
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doPrecomputeDistancesNN(objectDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation'); 
imagesPath = fullfile(dbBasePath, 'Images');
objectDbPath = fullfile(basePath, 'objectDb');
databasesPath = fullfile(basePath, 'databases');
concatHistoPath = fullfile(basePath, 'globalMeasures', 'concatHisto');
indPath = fullfile(basePath, 'illuminationContext', 'concatHistograms');

outputBasePath = dbPath;

dbFn = @dbFnPrecomputeDistancesNN;

% colorSpaces = {'lab', 'lalphabeta'};
colorSpaces = {'lalphabeta'};
types = {'jointObj', 'jointBg', 'margObj', 'margBg'};
nbBins = 50;

load(fullfile(indPath, sprintf('indActiveLab_%d.mat', nbBins)));
load(fullfile(indPath, sprintf('indActiveHsv_%d.mat', nbBins)));
load(fullfile(indPath, sprintf('indActiveLalphabeta_%d.mat', nbBins)));

if nargin ~= 1
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end

global lockAppend;
for i=1:length(colorSpaces)
    if strcmp(colorSpaces{i}, 'lab')
        activeInd = indActiveLab;
    elseif strcmp(colorSpaces{i}, 'hsv')
        activeInd = indActiveHsv;
    elseif strcmp(colorSpaces{i}, 'lalphabeta')
        activeInd = indActiveLalphabeta;
    end
    for t=1:length(types)
        % get the number of concatenated histograms
        nb = 0;
        files = dir(fullfile(concatHistoPath, sprintf('concatHisto_%s_%s*', colorSpaces{i}, types{t})));
        if length(files)
            str = sprintf('concatHisto_%s_%s_%%04d.mat', colorSpaces{i}, types{t});
            nb = sscanf(files(end).name, str);
        end
        
        for j=0:nb
            histoPath = fullfile(concatHistoPath, sprintf('concatHisto_%s_%s_%04d.mat', colorSpaces{i}, types{t}, j));
            fprintf('Loading %s...\n', histoPath);
            load(histoPath);
            
            % call the database function
            parallelized = 1;
            randomized = 1;
            lockAppend = sprintf('%s_%s_%d', colorSpaces{i}, types{t}, j);
            processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized, ...
                'ColorSpace', colorSpaces{i}, 'DbPath', dbPath, 'ObjectDbPath', objectDbPath, ...
                'ImagesPath', imagesPath, 'ConcatHisto', concatHisto, 'Type', types{t}, ...
                'ActiveInd', activeInd, 'NbBins', nbBins, 'NbDistances', length(objectDb));
            
            % clear the histogram
            clear('concatHisto');
        end
    end
end
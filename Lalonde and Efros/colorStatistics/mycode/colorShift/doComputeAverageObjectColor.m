%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doComputeAverageObjectColor
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doComputeAverageObjectColor(objectDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath ../;
setPath;

global globAccHisto;

% define the input and output paths
basePath= '/nfs/hn01/jlalonde/results/colorStatistics';
imagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'colorShift', 'avgHistograms');
dbFn = @dbFnComputeAverageObjectColor;

% load databases
if nargin == 0
    fprintf('Loading object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end
% load indices corresponding to keywords
load(fullfile(databasesPath, 'keywordIndices.mat'));

nbBins = 100;
for keywordInd=1:length(topKeywords) %#ok
    globAccHisto = zeros(nbBins, nbBins, nbBins);

    parallelized = 0;
    randomized = 0;
    processDatabase(objectDb(topIndices{keywordInd}), outputBasePath, dbFn, parallelized, randomized, ...
        'document', 'image.filename', 'image.folder', ...
        'ImagesPath', imagesPath, 'NbBins', nbBins); %#ok

    accHisto = globAccHisto; %#ok
    save(fullfile(outputBasePath, sprintf('%s.mat', topKeywords{keywordInd})), 'accHisto');
end


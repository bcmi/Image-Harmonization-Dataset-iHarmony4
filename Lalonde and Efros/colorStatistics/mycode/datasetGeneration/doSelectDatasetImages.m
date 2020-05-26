%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doSelectDatasetImages
%   Select the "best" synthetic images by looking at the overlap score between the previous and the
%   new object. Select the best for each keyword, by keeping the same occurence proportion (reflects
%   the amount of each object present in the original database). Also select real images randomly.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doSelectDatasetImages(syntheticDb, realDb, topKeywords)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
datasetBasePath = fullfile(basePath, 'dataset');

syntheticPath = fullfile(datasetBasePath, 'syntheticDb');
syntheticDbPath = fullfile(syntheticPath, 'Annotation');
syntheticImagesPath = fullfile(syntheticPath, 'Images');

realPath = fullfile(datasetBasePath, 'realDb');
realDbPath = fullfile(realPath, 'Annotation');
realImagesPath = fullfile(realPath, 'Images');

outputPath = fullfile(datasetBasePath, 'combinedDb');
outputDbPath = fullfile(outputPath, 'Annotation');
outputImagesPath = fullfile(outputPath, 'Images');

% create the directories
[m,m,m] = mkdir(outputPath); %#ok
[m,m,m] = mkdir(outputDbPath); %#ok
[m,m,m] = mkdir(outputImagesPath); %#ok
[m,m,m] = mkdir(fullfile(outputDbPath, 'masks')); %#ok


%% Read the full database of generated images
if nargin == 0
    fprintf('Loading databases...');
    % assume pre-loaded database
    syntheticDb = loadDatabaseFast(syntheticDbPath, '.');
    save(fullfile(basePath, 'databases', 'syntheticDb.mat'), 'syntheticDb');
    
    realDb = loadDatabaseFast(realDbPath, '.');
    save(fullfile(basePath, 'databases', 'realDb.mat'), 'realDb');
    
    load(fullfile(basePath, 'databases', 'keywordIndices.mat'));
    fprintf('done.\n');
end

% Total number of images we want to retain
totNbImages = 2500;

%% Select images to keep for each keyword
fprintf('Selecting images for each keyword...');

% Get the keywords from each entry in the database
keywords = arrayfun(@(x) x.document.object.keyword, syntheticDb, 'UniformOutput', 0);
scores = arrayfun(@(x) str2double(x.document.score), syntheticDb);

indToKeep = [];
for i=1:length(topKeywords)
    indKeyword = find(strcmp(keywords, topKeywords{i}));
    nbInstancesToKeep = round(length(indKeyword) / length(syntheticDb) * totNbImages);

    % sort the instances by using their scores
    [s, sortedInd] = sort(scores(indKeyword), 'descend');
    topInstancesInd = sortedInd(1:nbInstancesToKeep);
    
    % get the database indices
    topInstancesInd = indKeyword(topInstancesInd);
    
    indToKeep = [indToKeep topInstancesInd]; %#ok
end
fprintf('done.\n');

%% Loop over all the indices to keep, and copy the files to the output directory
for i=indToKeep
    imgInfo = syntheticDb(i).document;
    fprintf('Copying %s...\n', fullfile(imgInfo.file.folder, imgInfo.file.filename));
    
    inputDbFile = fullfile(syntheticDbPath, imgInfo.file.folder, imgInfo.file.filename);
    inputImageFile = fullfile(syntheticImagesPath, imgInfo.image.folder, imgInfo.image.filename);
    inputMaskFile = fullfile(syntheticDbPath, imgInfo.file.folder, imgInfo.object.masks.filename);
    
    outputDbFile = fullfile(outputDbPath, imgInfo.file.folder, imgInfo.file.filename);
    outputImageFile = fullfile(outputImagesPath, imgInfo.image.folder, imgInfo.image.filename);
    outputMaskFile = fullfile(outputDbPath, imgInfo.file.folder, imgInfo.object.masks.filename);

    % copy the files
    s1=copyfile(inputDbFile, outputDbFile);
    s2=copyfile(inputImageFile, outputImageFile);
    s3=copyfile(inputMaskFile, outputMaskFile);
    
    if ~s1 || ~s2 || ~s3, error('Error in copying file'); end
end
fprintf('done.\n');

%% Select real images
indToKeep = randperm(length(realDb));
indToKeep = indToKeep(1:totNbImages);

for i=indToKeep
    imgInfo = realDb(i).document;
    fprintf('Copying %s...\n', fullfile(imgInfo.file.folder, imgInfo.file.filename));
    
    inputDbFile = fullfile(realDbPath, imgInfo.file.folder, imgInfo.file.filename);
    inputImageFile = fullfile(realImagesPath, imgInfo.image.folder, imgInfo.image.filename);
    inputMaskFile = fullfile(realDbPath, imgInfo.file.folder, imgInfo.object.masks.filename);
    
    outputDbFile = fullfile(outputDbPath, imgInfo.file.folder, imgInfo.file.filename);
    outputImageFile = fullfile(outputImagesPath, imgInfo.image.folder, imgInfo.image.filename);
    outputMaskFile = fullfile(outputDbPath, imgInfo.file.folder, imgInfo.object.masks.filename);

    % copy the files
    s1=copyfile(inputDbFile, outputDbFile);
    s2=copyfile(inputImageFile, outputImageFile);
    s3=copyfile(inputMaskFile, outputMaskFile);
    
    if ~s1 || ~s2 || ~s3, error('Error in copying file'); end
end

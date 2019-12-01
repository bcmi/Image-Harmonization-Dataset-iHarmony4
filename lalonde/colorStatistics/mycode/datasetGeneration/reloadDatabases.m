%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function reloadDatabases
%   Loads the databases from their original formats, saves them to .mat file, crops them, and
%   computes the indices of each available keyword. Should be run each time anytime a database is
%   modified.
% 
% Input parameters:
%   - doSkipXML: Whether to re-load the databases from the xml data or use a pre-loaded .mat file
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function reloadDatabases(doSkipXML) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

if nargin == 0
    doSkipXML = 0;
end

basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
objectDbPath = fullfile(basePath, 'objectDb');
imageDbPath = fullfile(basePath, 'imageDb');
outputPath = fullfile(basePath, 'databases');

%% Load the databases
if ~doSkipXML
    fprintf('Loading the object database...\n');
    objectDb = loadDatabaseFast(objectDbPath, '*static*');

    fprintf('Loading the image database...\n');
    imageDb = loadDatabaseFast(imageDbPath, '*static*');
end
%% Save the original databases
if ~doSkipXML
    fprintf('Saving the original object database...\n');
    save(fullfile(objectDbPath, 'objectDb.mat'), 'objectDb');

    fprintf('Saving the original image database...\n');
    save(fullfile(imageDbPath, 'imageDb.mat'), 'imageDb');
end
%% Load the original databases
if doSkipXML
    fprintf('Loading the original object database...\n');
    load(fullfile(objectDbPath, 'objectDb.mat'));

    fprintf('Loading the original image database...\n');
    load(fullfile(imageDbPath, 'imageDb.mat'));
end

%% Filter "bad" images and objects
fprintf('Filtering ''bad'' images and objects...\n');
[imageInd, objectInd, objectToImageInd] = filterDatabases(imageDb, objectDb); %#ok
save(fullfile(outputPath, 'objImgIndices.mat'), 'imageInd', 'objectInd', 'objectToImageInd');

%% Save the cropped databases
objectDb = objectDb(objectInd);
imageDb = imageDb(imageInd); %#ok

fprintf('Saving the cropped object database...\n');
save(fullfile(outputPath, 'objectDb.mat'), 'objectDb');

fprintf('Saving the cropped image database...\n');
save(fullfile(outputPath, 'imageDb.mat'), 'imageDb');

%% Get the keywords and their indices
fprintf('Retrieving keywords and their indices...\n');
minNbObjects = 20;
[topKeywords, topIndices] = getIndicesKeywords(objectDb, minNbObjects); %#ok
save(fullfile(outputPath, 'keywordIndices.mat'), 'topKeywords', 'topIndices', 'minNbObjects');
fprintf('done.\n');

%% Grouping the keywords' masks
fprintf('Grouping the keyword''s masks...\n');
groupKeywordMasks(objectDb, topKeywords, topIndices);
fprintf('done.\n');

function mergePrecomputedUniversalTextons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global globFilteredPx;

addpath ../;
setPath;

dbPath = '/nfs/hn01/jlalonde/results/colorStatistics';
databasesPath = fullfile(dbPath, 'databases');
imageDbPath = fullfile(dbPath, 'imageDb');
load(fullfile(databasesPath, 'imageDb.mat'));

nbClusters = 1000;

% load all the pixels into one huge structure
dbFn = @dbFnLoadFilteredPx;
parallelized = 0;
randomized = 0;
globFilteredPx = cell(1, length(imageDb));
processDatabase(imageDb, imageDbPath, dbFn, parallelized, randomized, ...
    'document', 'image.filename', 'image.folder');

% save the global variable
save(fullfile(dbPath, 'illuminationContext', 'textons', 'globFilteredPx.mat'), '-v7.3', 'globFilteredPx');

function r = dbFnLoadFilteredPx(outputBasePath, annotation, varargin) 
global globFilteredPx processDatabaseImgNumber;
r = 0;  

if isfield(annotation, 'univTextons')
    file = fullfile(outputBasePath, annotation.file.folder, annotation.univTextons.filename);
    load(file);
   
    globFilteredPx{processDatabaseImgNumber} = filteredPx;
end

a=whos('globFilteredPx');
fprintf('Total size: %fMB\n', a.bytes/(1024^2));

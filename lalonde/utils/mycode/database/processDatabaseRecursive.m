%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processImageDatabase(basePath, currentPath, includeStrings, excludeStrings, outputBasePath, dbFn, ...
%    parallelized, randomized, logFileId, varargin)
%  Recursive function that processes all the files in an image repository
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nbErrors = processDatabaseRecursive(basePath, currentPath, includeStrings, excludeStrings, outputBasePath, dbFn, ...
    parallelized, randomized, logFileId, varargin)

% ext = '.jpg';
ext = '';

excludeStrings = cat(2, excludeStrings, {'.*'});

% Read all the files in the specified directory
files = getFilesFromDirectory(basePath, currentPath, includeStrings, excludeStrings, ext, 0);

nbErrors = processDatabaseRecursiveFiles(basePath, currentPath, files, outputBasePath, dbFn, ...
    parallelized, randomized, logFileId, varargin{:});

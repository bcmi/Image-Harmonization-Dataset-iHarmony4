%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function db = loadDatabaseFast(databasePath, subDirectories, excludeStrings, recurse) 
%   Loads a database by reading several xml files. Wrapper around
%   loadDatabaseFiles.
% 
% Input parameters:
%   - databasePath: path to the database
%   - subDirectories: cell array of subdirectories to process
%
% Output parameters:
%
% Warning:
%   Assumes that the databasePath follows pretty much the same structure as the labelme database.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function db = loadDatabaseFast(databasePath, subDirectories, excludeStrings, recurse) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    subDirectories = '';
end

if nargin < 3
    excludeStrings = '';
end

if nargin < 4
    recurse = 1;
end

% Read all the files in the specified directory
% [files, directories] = getFilesFromSubdirectories(databasePath, subDirectories, 'xml');
[files, directories] = getFilesFromDirectory(databasePath, '.', subDirectories, excludeStrings, 'xml', recurse);
db = loadDatabaseFiles(databasePath, files, directories);


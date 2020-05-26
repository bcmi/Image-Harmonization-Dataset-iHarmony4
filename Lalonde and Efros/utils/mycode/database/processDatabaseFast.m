%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processDatabaseFast(basePath, includeStrings, excludeStrings, ...
%   outputBasePath, dbFn, parallelized, randomized, topField, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each image found. 
% 
% Input parameters:
%   - basePath: path to the base of the database
%   - includeStrings: string(s) that *must* be present in the file names
%   - excludeStrings: string(s) that *must not* be present in the file names (anywhere)
%   - outputBasePath: location of the top-level results directory. 
%     Will automatically create subdirectories at that location.
%   - dbFn: function to be executed on each image. Must take care of saving
%     whatever results it wants.
%   - parallelized: whether to parallelize the process or not
%   - randomized: whether to randomize the order or not
%   - varargin: additional parameters to dbFn
%       (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processDatabaseFast(basePath, includeStrings, excludeStrings, ...
    outputBasePath, dbFn, parallelized, randomized, topField, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Read all the files in the specified directory
% [files, directories] = getFilesFromSubdirectories(basePath, subDirectories, 'xml');
% Read all the files in the specified directory
[files, directories] = getFilesFromDirectory(basePath, '.', includeStrings, excludeStrings, '.xml', 1);

% Call the database files function
processDatabaseFiles(basePath, files, directories, outputBasePath, dbFn, parallelized, randomized, topField, varargin{:});

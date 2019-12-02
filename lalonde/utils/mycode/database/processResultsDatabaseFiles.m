%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processResultsDatabaseFiles(basePath, files, directories,
% outputBasePath, dbFn, parallelized, randomized, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each image found. Does not pre-load the database
% 
% Input parameters:
%   - files: list of files to process
%   - directories: list of directories to process (corresponding to files)
%   - dbFn: function to be executed on each xml file. Must take care of saving
%     whatever results it wants.
%   - varargin: additional parameters to apss to dbFn
%       (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processResultsDatabaseFiles(basePath, files, directories, outputBasePath, dbFn, parallelized, randomized, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simply call the database function
processDatabaseFiles(basePath, files, directories, outputBasePath, ...
    dbFn, parallelized, randomized, [], varargin{:});


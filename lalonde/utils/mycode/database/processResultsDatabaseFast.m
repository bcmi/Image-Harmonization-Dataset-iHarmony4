%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processResultsDatabaseFast(basePath, includeStrings, excludeStrings, outputBasePath, dbFn, parallelized, randomized, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each image found. Does not pre-load the database
% 
% Input parameters:
%   - basePath: location of the top-level db directory
%   - subDirs: the sub-directories to process
%   - dbFn: function to be executed on each xml file. Must take care of saving
%     whatever results it wants.
%   - varargin: additional parameters to apss to dbFn
%       (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processResultsDatabaseFast(basePath, includeStrings, excludeStrings, outputBasePath, dbFn, parallelized, randomized, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Simply call the database function
processDatabaseFast(basePath, includeStrings, excludeStrings, outputBasePath, ...
    dbFn, parallelized, randomized, [], varargin{:});


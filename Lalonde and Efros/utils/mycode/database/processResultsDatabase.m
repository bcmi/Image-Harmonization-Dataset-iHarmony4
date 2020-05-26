%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processResultsDatabase(dbPath, subDirs, outputBasePath, dbFn, parallelized, randomized, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each image found. 
% 
% Input parameters:
%   - dbPath: location of the top-level db directory
%   - subDirs: the sub-directories to process
%   - outputBasePath: the path where to save the results
%   - dbFn: function to be executed on each xml file. Must take care of saving
%     whatever results it wants.
%   - varargin: additional parameters to apss to dbFn
%       (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processResultsDatabase(dbPath, subDirs, outputBasePath, dbFn, parallelized, randomized, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% the database may be pre-loaded
if strfind(dbPath, '.mat')
    fprintf('Previously loaded database...\n');
    load(dbPath);
else
    % load the database
    fprintf('Loading database...\n');
    if isempty(subDirs)
        subDirs = {'.'};
    elseif ~iscell(subDirs)
        list = dir(fullfile(dbPath, subDirs));
        cellList = struct2cell(list);
        subDirs = cellList(1,:);
    end
    D = loadDatabaseFast(dbPath, subDirs);
end

% process the database!
processDatabase(D, outputBasePath, dbFn, parallelized, randomized, 'filename', 'folder', varargin{:});

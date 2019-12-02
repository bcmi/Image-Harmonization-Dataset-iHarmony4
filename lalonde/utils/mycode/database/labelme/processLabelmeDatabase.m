%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function processLabelmeDatabase(subDirs, annotationsBasePath, outputBasePath, dbFn, parallelized, randomized, varargin)
%  Goes over the entire database (specified as input), and performs some
%  processing on each image found. 
% 
% Input parameters:
%   - trainingImagesSubDirs: list of sub-directories to consider.
%   - annotationsBasePath: location of the top-level annotations directory.
%     Must follow the LabelMe convention.
%   - outputBasePath: location of the top-level results directory. 
%     Will automatically create subdirectories at that location.
%   - dbFn: function to be executed on each image. Must take care of saving
%     whatever results it wants.
%   - parallelized: whether to parallelize the process or not
%   - randomized: whether to randomize the process or not
%   - varargin: additional parameters to apss to dbFn
%       (application-specific)
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processLabelmeDatabase(basePath, subDirs, outputBasePath, dbFn, parallelized, randomized, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% load the database
if isempty(subDirs)
    D = LMdatabase(basePath);
else
    if ~iscell(subDirs)
        list = dir(fullfile(basePath, subDirs));
        cellList = struct2cell(list);
        subDirs = cellList(1,:);
    end
    D = LMdatabase(basePath, subDirs);
end

processDatabase(D, basePath, outputBasePath, dbFn, parallelized, randomized, ...
    'annotation', 'filename', 'folder', varargin{:});


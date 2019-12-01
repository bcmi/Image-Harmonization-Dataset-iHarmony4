%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doFixObjectFilenames
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doFixObjectFilenames 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
addpath ../../../3rd_party/LabelMeToolbox/;

% define the paths
dbPath = '/nfs/hn24/home/jlalonde/results/colorStatistics/objectDb/';
outputBasePath = dbPath;

dbFn = @dbFnFixObjectFilenames;

% call the database
parallelized = 1;
randomized = 1;
processResultsDatabaseFast(dbPath, '*static*', outputBasePath, dbFn, parallelized, randomized);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnFixObjectFilenames(outputBasePath, annotation, varargin)

[path, filename] = fileparts(annotation.image.filename);

filename = sprintf('%s_%04d.xml', filename, str2double(annotation.object.objectId));

annotation.filename = filename;
annotation.folder = annotation.image.folder;

writeXML(fullfile(outputBasePath, annotation.folder, annotation.filename), annotation);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCleanupOnlineXml
%   Cleans up the xml to be put online to retain only the masks
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCleanupOnlineXml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
dbBasePath = fullfile(basePath, 'dataset', 'onlineDb');
dbPath = fullfile(dbBasePath, 'tmp');
outputBasePath = fullfile(dbBasePath, 'Annotation');

dbFn = @dbFnCleanupOnlineXml;

%% call the database function
parallelized = 0;
randomized = 0;
processResultsDatabaseFast(dbPath, '', outputBasePath, dbFn, parallelized, randomized);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCleanupOnlineXml(annotation, dbPath, outputBasePath, varargin)
%   
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnCleanupOnlineXml(outputBasePath, annotation, varargin) 
r=0;

% read arguments
defaultArgs = struct();
args = parseargs(defaultArgs, varargin{:});

% keep only the relevant information
objInfo.image = annotation.image;
objInfo.file = annotation.file;
objInfo.object = annotation.object;
objInfo.objImgSrc = annotation.objImgSrc;
objInfo.bgImgSrc = annotation.bgImgSrc;

outputFile = fullfile(outputBasePath, objInfo.file.folder, objInfo.file.filename);
writeXML(outputFile, objInfo);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function convertWildDatabase
%   Converts the WILD database to my own xml format (for easy retrieval of ground truth, etc)  
% 
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function convertWildDatabase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath ../;
addpath ../../../3rd_party/wild;
addpath ../../../3rd_party/LabelMeToolbox;
addpath ../../../3rd_party/parseArgs;

basePath = '/usr3/jlalonde/WILD/database';
outputBasePath = '/usr3/jlalonde/WILD/wildDb';

dbFn = @dbFnConvertWildDatabase;

parallelized = 0;
randomized = 0;
processImageDatabase(basePath, [], [], outputBasePath, dbFn, ...
    parallelized, randomized, 'DbPath', basePath);

function r=dbFnConvertWildDatabase(outputBasePath, annotation, varargin)
r=0;

defaultArgs = struct('DbPath', []);
args = parseargs(defaultArgs, varargin{:});

% get the ground truth file
gtFile = fullfile(args.DbPath, annotation.file.folder, 'GroundTruth.html');

if exist(gtFile, 'file')

    % convert ground truth to xml
    annotation.gt.visibility = getgroundtruth('Visibility', gtFile);
    annotation.gt.skyConditions = getgroundtruth('Sky conditions', gtFile);
    annotation.gt.relHumidity = getgroundtruth('Relative Humidity', gtFile);
    annotation.gt.temperature = getgroundtruth('Temperature', gtFile);
    annotation.gt.dewPoint = getgroundtruth('Dew Point', gtFile);
    annotation.gt.weather = getgroundtruth('Weather', gtFile);

    [s,rem] = strtok(annotation.file.folder, filesep);
    [annotation.date.year, rem] = strtok(rem, filesep);
    [annotation.date.month, rem] = strtok(rem, filesep);
    [annotation.date.day, rem] = strtok(rem, filesep);
    annotation.date.hour = strtok(rem, filesep);
    annotation.date.month = lower(annotation.date.month);

    % save xml
    outputFile = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
    [s,s,s] = mkdir(fileparts(outputFile)); %#ok
    writeXML(outputFile, annotation);

end
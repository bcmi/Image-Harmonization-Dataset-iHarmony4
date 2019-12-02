%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doConvertRecoloringToHtml
%   Writes the results of recoloring to an html file for easy and fast visualization.
%   Uses pre-computed recoloring results.
% 
% Input parameters:
%
% Output parameters:
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doConvertRecoloringToHtml(syntheticDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');
databasesPath = fullfile(basePath, 'databases');
outputHtmlPath = fullfile('colorStatistics', 'recoloring', 'finalVersion');
compiledResultsPath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');

dbFn = @dbFnRecoloringToHtml;

%% Load the database
if nargin ~= 1
    fprintf('Loading the databases...');
    load(fullfile(databasesPath, 'syntheticDb.mat'));
    fprintf('done.\n');
end

% load the indices and scores
load(fullfile(databasesPath, 'userIndicesTrainTest.mat'));
load(fullfile(compiledResultsPath, 'compiledResults.mat')); 

%% Get the scores

% Get best local score
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'objBgDst')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'localEval')); %#ok

scoresLocal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

% Get best global scores
c = find(strcmp(colorSpaces, 'lab')); %#ok
t = find(strcmp(techniques, 'jointObjColorTexton_threshold_75')); %#ok
dt = find(strcmp(distances, 'distChi')); %#ok
ei = find(strcmp(evalName, 'globalEval')); %#ok

scoresGlobal = mysqueeze(scores2ndOrder(ei, c, :, t, dt)); %#ok

globalThreshold = 0.35;
[scores, indGlobal] = combineLocalAndGlobalScores(scoresLocal, scoresGlobal, globalThreshold);


%% Setup html stuff
htmlInfo = [];
[htmlInfo.experimentNb, htmlInfo.outputDirExperiment, htmlInfo.outputDirFig, ...
    htmlInfo.outputDirJpg, htmlInfo.outputHtmlFileName] = setupBatchTest(outputHtmlPath, '');

global cellArray;

% build html structure title row
cellArray = cell(1,7);
cellArray(1,:) = {'Composite image', 'Nearest-neighbor', 'Local', 'Global', 'Type', 'Label', 'Score'};

%% Call the database function
parallelized = 0;
randomized = 0;
indices = [indUnrealistic; indRealistic; indReal];
gtLabel = [ones(length(indUnrealistic), 1); 2.*ones(length(indRealistic), 1); 3.*ones(length(indReal), 1)];
processDatabase(syntheticDb(indices), htmlInfo.outputDirExperiment, dbFn, parallelized, randomized, 'document', 'image.filename', 'image.folder', ...
    'DbPath', dbPath, 'ImagesPath', imagesPath, 'HtmlInfo', htmlInfo, ...
    'IndGlobal', indGlobal(indices), 'Scores', scores(indices), 'GtLabel', gtLabel);

% append to html
cell2html(cellArray, htmlInfo.outputHtmlFileName, ...
    'StandAlone', false, 'Caption', 'Recoloring results', ...
    'StyleClass', 'results', 'StyleSheet', '../../../style.css');

%%
function r=dbFnRecoloringToHtml(outputBasePath, annotation, varargin)
global cellArray processDatabaseImgNumber;
r=0;

%% Initialize
% read arguments
defaultArgs = struct('DbPath', [], 'ImagesPath', [], 'HtmlInfo', [], 'IndGlobal', [], 'Scores', [], 'GtLabel', []);
args = parseargs(defaultArgs, varargin{:});

[f,name] = fileparts(annotation.image.filename);

img = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));
imgNN = imread(fullfile(args.DbPath, annotation.image.folder, annotation.recoloredImage.nn));
imgLocal = imread(fullfile(args.DbPath, annotation.image.folder, annotation.recoloredImage.loc));
imgGlobal = imread(fullfile(args.DbPath, annotation.image.folder, annotation.recoloredImage.glob));

% save the original image
outFn = sprintf('%s.jpg', name);
outFnNN = sprintf('%s_NN.jpg', name);
outFnLocal = sprintf('%s_local.jpg', name);
outFnGlobal = sprintf('%s_global.jpg', name);

imwrite(img, fullfile(args.HtmlInfo.outputDirJpg, outFn), 'Quality', 75);
imwrite(imgNN, fullfile(args.HtmlInfo.outputDirJpg, outFnNN), 'Quality', 75);
imwrite(imgLocal, fullfile(args.HtmlInfo.outputDirJpg, outFnLocal), 'Quality', 75);
imwrite(imgGlobal, fullfile(args.HtmlInfo.outputDirJpg, outFnGlobal), 'Quality', 75);

type = 'lg';
label = 'url';

cellArray(processDatabaseImgNumber+1, :) = {...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFn), fullfile('jpg', outFn), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFnNN), fullfile('jpg', outFnNN), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFnLocal), fullfile('jpg', outFnLocal), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFnGlobal), fullfile('jpg', outFnGlobal), 'Width', 200), ...
    sprintf('%s', type(args.IndGlobal(processDatabaseImgNumber)+1)), ...
    sprintf('%s', label(args.GtLabel(processDatabaseImgNumber))), ...
    sprintf('%.02f', args.Scores(processDatabaseImgNumber))....
    };

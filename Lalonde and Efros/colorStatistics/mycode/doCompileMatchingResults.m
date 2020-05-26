%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doCompileMatchingResults
%   Scripts that compiles the matching results, accumulated over several images. New and improved
%   version.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doCompileMatchingResults(doSkipXml)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
setPath;

if nargin ~= 1
    doSkipXml = 0;
end

% define the input and output paths
% basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
dbPath = fullfile(basePath, 'matchingEvaluation');
outputBasePath = fullfile(basePath, 'matchingEvaluation', 'compiledResults');
databasesPath = fullfile(basePath, 'databases');

dbFn = @dbFnCompileMatchingResults;

% initialize the color spaces
colorSpaces = [];
colorSpaces = [colorSpaces; {'lab', 1}];
% colorSpaces = [colorSpaces {{'rgb'},2}];
colorSpaces = [colorSpaces; {'hsv',3}];
colorSpaces = [colorSpaces; {'lalphabeta',4}];

% different distances
distances = [];
distances = [distances {'distChi'}];
% distances = [distances {'distDot'}];
% distances = [distances {'klDiv'}];
% distances = [distances {'prob'}];
distances = [distances {'distEMD'}];
distances = [distances {'distEMDWeighted'}];


techniques = [];

% local techniques
techniques = [techniques {'objBgDst'}];
% techniques = [techniques {'objBgSrc'}];
techniques = [techniques {'objBgDstW'}];
techniques = [techniques {'objBgDstWS'}];
% techniques = [techniques {'objBgSrcW'}];
% techniques = [techniques {'bgBg'}];
% techniques = [techniques {'bgBgW'}];
techniques = [techniques {'objBgDstTextonW'}];
techniques = [techniques {'objBgDstTextonColorW'}];

% global techniques
techniques = [techniques {'jointObj_75'}];
techniques = [techniques {'jointObj_50'}];
techniques = [techniques {'jointObj_25'}];
techniques = [techniques {'margObj_75'}];
techniques = [techniques {'margObj_50'}];
techniques = [techniques {'margObj_25'}];
techniques = [techniques {'jointObj_threshold'}];
techniques = [techniques {'jointBg_threshold'}];
techniques = [techniques {'margObj_threshold'}];
techniques = [techniques {'margBg_threshold'}];

techniques = [techniques {'jointObjColorTexton_threshold_0'}];
techniques = [techniques {'jointObjColorTexton_threshold_25'}];
techniques = [techniques {'jointObjColorTexton_threshold_50'}];
techniques = [techniques {'jointObjColorTexton_threshold_75'}];
techniques = [techniques {'jointObjColorTexton_threshold_100'}];

techniques = [techniques {'jointBgColorTexton_threshold_0'}];
techniques = [techniques {'jointBgColorTexton_threshold_25'}];
techniques = [techniques {'jointBgColorTexton_threshold_50'}];
techniques = [techniques {'jointBgColorTexton_threshold_75'}];
techniques = [techniques {'jointBgColorTexton_threshold_100'}];

techniques = [techniques {'jointObjColorTextonSingle_threshold_0'}];
techniques = [techniques {'jointObjColorTextonSingle_threshold_25'}];
techniques = [techniques {'jointObjColorTextonSingle_threshold_50'}];
techniques = [techniques {'jointObjColorTextonSingle_threshold_75'}];
techniques = [techniques {'jointObjColorTextonSingle_threshold_100'}];

techniques = [techniques {'jointBgColorTextonSingle_threshold_0'}];
techniques = [techniques {'jointBgColorTextonSingle_threshold_25'}];
techniques = [techniques {'jointBgColorTextonSingle_threshold_50'}];
techniques = [techniques {'jointBgColorTextonSingle_threshold_75'}];
techniques = [techniques {'jointBgColorTextonSingle_threshold_100'}];

evalName = [];
evalName = [evalName {'localEval'}];
evalName = [evalName {'globalEval'}];

% define and initialize the scores
global scores1stOrder scores2ndOrder;

files = getFilesFromSubdirectories(dbPath, '', 'xml');
nbImages = length(files);

scores1stOrder = zeros(length(evalName), length(colorSpaces), nbImages, length(techniques), length(distances));
scores2ndOrder = zeros(length(evalName), length(colorSpaces), nbImages, length(techniques), length(distances));

%% Load the database
if doSkipXml
    fprintf('Loading matching results database...'); tic;
    load(fullfile(databasesPath, 'matchingEvaluationDb.mat'));
    fprintf('done in %fs.\n', toc);
else
    fprintf('Loading matching evaluation database from xml...'); tic;
    matchingEvaluationDb = loadDatabaseFast(dbPath, '');
    save(fullfile(databasesPath, 'matchingEvaluationDb.mat'), 'matchingEvaluationDb');
    fprintf('done in %fs.\n', toc);
end

%% Loop over the database results
% call the database function
parallelized = 0;
randomized = 0;
processDatabase(matchingEvaluationDb, outputBasePath, dbFn, parallelized, randomized, ...
    'document', 'image.filename', 'image.folder', ...
    'ColorSpaces', colorSpaces, 'Techniques', techniques, 'Distances', distances, 'Eval', evalName);

delete(fullfile(outputBasePath, 'compiledResults.mat'));
save(fullfile(outputBasePath, 'compiledResults.mat'), 'scores1stOrder', 'scores2ndOrder', ...
    'colorSpaces', 'techniques', 'distances', 'nbImages', 'evalName');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doNNMatchingToHtml
%   Writes the result of nearest-neighbor matching to an html file for easy visualization.
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doNNMatchingToHtml(objectDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');
databasesPath = fullfile(basePath, 'databases');
outputBasePath = fullfile(basePath, 'matchingEvaluation');
outputHtmlPath = 'colorStatistics/NNMatching';

% colorSpaces = {'lab', 'lalphabeta'};
colorSpace = {'lab'}; % lalphabeta is not ready yet (run doPrecomputeDistancesNN)
type = 'jointObj';
compType = 'jointBg';
dbFn = @dbFnNNMatchingToHtml;

%% Load the database
if nargin ~= 1
    fprintf('Loading the object database...');
    load(fullfile(databasesPath, 'objectDb.mat'));
    fprintf('done.\n');
end

%% Setup html stuff
htmlInfo = [];
[htmlInfo.experimentNb, htmlInfo.outputDirExperiment, htmlInfo.outputDirFig, ...
    htmlInfo.outputDirJpg, htmlInfo.outputHtmlFileName] = setupBatchTest(outputHtmlPath, '');
global count;
count = 0;

%% Call the database function
parallelized = 0;
randomized = 1;
processResultsDatabaseFast(dbPath, 'image_1', outputBasePath, dbFn, parallelized, randomized, ...
    'ColorSpace', colorSpace, 'DbPath', dbPath, 'ImagesPath', imagesPath, 'ObjectDb', objectDb, ...
    'Type', type, 'CompType', compType, 'HtmlInfo', htmlInfo, 'SubsampledImagesPath', subsampledImagesPath);

%%
function r=dbFnNNMatchingToHtml(outputBasePath, annotation, varargin)
global count;
r=0;

%% Initialize
% read arguments
defaultArgs = struct('ColorSpace', [], 'Type', [], 'CompType', [], 'DbPath', [], 'ImagesPath', [], ...
    'ObjectDb', [], 'HtmlInfo', [], 'SubsampledImagesPath', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
img = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));
% load the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename)); %bgMask, objMask
% draw the object outline
objOutline = bwperim(objMask);
iB = repmat(zeros(size(img,1), size(img,2)), [1 1 2]);
iB(:,:,3) = objOutline;
img(repmat(objOutline, [1 1 2])) = 0;
img(find(iB)) = 255;

%% Find the corresponding object and background image in the database
fprintf('Finding indices in the database...');
objImgInd = getDatabaseIndexFromFilename(args.ObjectDb, 'document', annotation.objImgSrc.folder, annotation.objImgSrc.filename);
bgImgInd = getDatabaseIndexFromFilename(args.ObjectDb, 'document', annotation.bgImgSrc.folder, annotation.bgImgSrc.filename);
fprintf('done.');

%% Compute nearest neighbor for each type and each color space
fprintf('Computing nearest-neighbors...');
% Loop over all color spaces
if strcmp(args.ColorSpace, 'lab')
    colorType = 1;
elseif strcmp(args.ColorSpace, 'lalphabeta')
    colorType = 4;
else
    error('Unsupported color type!');
end

% Load the complementary distance (object - background)
compDistancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distNN.(args.CompType)(colorType).distChi.filename);
load(compDistancesFile);
compDistances = distances;

% Load the distance file
distancesFile = fullfile(args.DbPath, annotation.file.folder, annotation.global.distNN.(args.Type)(colorType).distChi.filename);
load(distancesFile);
origDistances = distances;

% only keep the valid distances
validOrigInd = origDistances >= 0;
validCompInd = compDistances >= 0;

% both must be valid
validInd = find(validOrigInd & validCompInd);
% remove the original images from the list
validInd = setdiff(validInd, [objImgInd bgImgInd]);

% prepare the output file names
[path, name] = fileparts(annotation.file.filename);
% build html structure title row
cellArray(1,:) = {'Composite image', 'Obj=25%, Bg=75%', 'Obj=50%, Bg=50%', 'Obj=75%, Bg=25%'};

% save the original image
outFn = sprintf('%s.jpg', name);
imwrite(img, fullfile(args.HtmlInfo.outputDirJpg, outFn));
cellArray(2, 1) = {img2html(fullfile(args.HtmlInfo.outputDirJpg, outFn), fullfile('jpg', outFn), 'Width', 200)};

% the final distance is the minimum of a weighted combination of the background and object distances
alphas = [0.25 0.5 0.75];
for alpha=alphas
    dist = alpha.*origDistances(validInd) + (1-alpha).*compDistances(validInd);
    [m, mInd] = min(dist);

    nnInfo = args.ObjectDb(validInd(mInd)).document;
    nnPath = fullfile(args.SubsampledImagesPath, nnInfo.image.folder, nnInfo.image.filename);
    nnImg = imread(nnPath);
    
    % highlight the polygon
    nnPolygon = getPoly(nnInfo.object.polygon);
    nnPolygon = [nnPolygon; nnPolygon(1,:)];

    outFn = sprintf('%s_%d.jpg', name, alpha*100);
    h = figure(1), imshow(nnImg), hold on, plot(nnPolygon(:,1), nnPolygon(:,2), 'b', 'LineWidth', 2);
    saveNiceFigure(h, fullfile(args.HtmlInfo.outputDirJpg, outFn), [size(img,1) size(img,2)]);
    close;
    
    cellArray(1, find(alphas==alpha)+1) = {sprintf('Obj=%d Bg=%d d=%0.2f', alpha*100, (1-alpha)*100, min(dist))};
    cellArray(2, find(alphas==alpha)+1) = {img2html(fullfile(args.HtmlInfo.outputDirJpg, outFn), fullfile('jpg', outFn), 'Width', 200)};
end
fprintf('done.\n');

% append to html
cell2html(cellArray, args.HtmlInfo.outputHtmlFileName, ...
    'StandAlone', false, 'Caption', annotation.image.filename, ...
    'StyleClass', 'results', 'StyleSheet', '../../../style.css');

count = count + 1;
if count > 200
    fprintf('Processed %d images. Done!\n', count);
    r = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doRecoloringToHtml
%   Writes the results of recoloring to an html file for easy and fast visualization.
% 
% Input parameters:
%
% Output parameters:
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doRecoloringToHtml
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
outputHtmlPath = 'colorStatistics/recoloring';

dbFn = @dbFnRecoloringToHtml;

%% Setup html stuff
htmlInfo = [];
[htmlInfo.experimentNb, htmlInfo.outputDirExperiment, htmlInfo.outputDirFig, ...
    htmlInfo.outputDirJpg, htmlInfo.outputHtmlFileName] = setupBatchTest(outputHtmlPath, '');
global count;
count = 0;

%% Call the database function
parallelized = 0;
randomized = 1;
processResultsDatabaseFast(dbPath, 'image_0', '', dbFn, parallelized, randomized, ...
    'DbPath', dbPath, 'ImagesPath', imagesPath, 'HtmlInfo', htmlInfo);

%%
function r=dbFnRecoloringToHtml(outputBasePath, annotation, varargin)
global count;
r=0;

%% Initialize
% read arguments
defaultArgs = struct('DbPath', [], 'ImagesPath', [], 'ObjectDb', [], 'HtmlInfo', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
imgOrig = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));
img = imgOrig;
% load the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename)); %bgMask, objMask
% draw the object outline
objOutline = bwperim(objMask);
iB = repmat(zeros(size(img,1), size(img,2)), [1 1 2]);
iB(:,:,3) = objOutline;
img(repmat(objOutline, [1 1 2])) = 0;
img(find(iB)) = 255;

% recolor the object based on the background colors
[imgTgtNN, imgTgtNNW, centersSrc, weightsSrc, centersTgt, weightsTgt, flowEMD, pixelShift] = ...
    recolorImageFromSignatures(imgOrig, imgOrig, find(bgMask), find(objMask));

% prepare the output file names
[path, name] = fileparts(annotation.file.filename);
% build html structure title row
cellArray(1,:) = {'Composite image', 'Signatures', 'Nearest cluster', 'Weighted clusters', 'Normalized color shift'};

% save the original image
outFn = sprintf('%s.jpg', name);
outFnNN = sprintf('%s_NN.jpg', name);
outFnNNW = sprintf('%s_NNW.jpg', name);
outFnSignatures = sprintf('%s_signatures.jpg', name);

imwrite(img, fullfile(args.HtmlInfo.outputDirJpg, outFn));
imwrite(imgTgtNN, fullfile(args.HtmlInfo.outputDirJpg, outFnNN));
imwrite(imgTgtNNW, fullfile(args.HtmlInfo.outputDirJpg, outFnNNW));

emdFig = figure(1); hold on;
plotEMD(emdFig, centersTgt, centersSrc, flowEMD);
plotSignatures(emdFig, centersTgt, weightsTgt, 'lab');
plotSignatures(emdFig, centersSrc, weightsSrc, 'lab');
title('EMD visualization'), xlabel('l'), ylabel('a'), zlabel('b'), view([-40 40]);
saveNiceFigure(emdFig, fullfile(args.HtmlInfo.outputDirJpg, outFnSignatures));
close;

cellArray(2, :) = {...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFn), fullfile('jpg', outFn), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFnSignatures), fullfile('jpg', outFnSignatures), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFnNN), fullfile('jpg', outFnNN), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, outFnNNW), fullfile('jpg', outFnNNW), 'Width', 200), ...
    sprintf('%.02f', max(mean(abs(pixelShift))))....
    };

% append to html
cell2html(cellArray, args.HtmlInfo.outputHtmlFileName, ...
    'StandAlone', false, 'Caption', annotation.image.filename, ...
    'StyleClass', 'results', 'StyleSheet', '../../../style.css');

count = count + 1;
if count > 200
    fprintf('Processed %d images. Done!\n', count);
    r = 1;
end
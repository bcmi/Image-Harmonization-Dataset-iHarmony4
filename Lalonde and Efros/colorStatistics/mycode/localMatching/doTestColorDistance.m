%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doTestColorDistance
%   Batch test of color distances
%
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doTestColorDistance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
% we will save everything to an html file
addpath ../;
setPath;

inputDir = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/filteredDb/Images/';
outputDirTopic = 'colorStatistics/colorDistance/';
files = getFilesFromSubdirectories(inputDir, '', 'jpg');

% description of the experiment (in html directly)
description = '';

% get experiment parameters
[experimentNb, outputDirExperiment, outputDirFig, outputDirJpg, outputHtmlFileName] = setupBatchTest(outputDirTopic, description);

% compute the color distance histograms
nbPixelsDistances = 500;
nbIter = 10;

% randomly select 200 images
nbImages = 200;
imageInd = randperm(length(files));

%% loop over all images
for i=1:imageInd(1:nbImages)
    % read the current image
    imFileName = files{i};
    
    fprintf('Processing %s...\n', imFileName);

    % load the image
    img = imread(fullfile(inputDir, imFileName));

    % Compute pairwise color distances over the entire image
    imgVector = reshape(img, size(img,1)*size(img,2), size(img,3));

    x = 1:5:400;
    accHistoRgb = computeColorDistanceHistogram(imgVector, x, nbIter, nbPixelsDistances);
    figRGB = figure(1); bar(x, accHistoRgb), xlim([0 max(x)]), title('RGB distances histogram', 'FontSize', 18);
    
    % Try in Lab
    imgLab = rgb2lab(img);
    imgVectorLab = reshape(imgLab, size(img,1)*size(img,2), size(img,3));

    x = 1:2:150;
    accHistoLab = computeColorDistanceHistogram(imgVectorLab, x, nbIter, nbPixelsDistances);
    figLAB = figure(2); bar(x, accHistoLab), xlim([0 max(x)]), title('Lab distances histogram', 'FontSize', 18);

    fig3D = figure(3); displayColors(imgVectorLab, imgVector);

    % Try just ab channels
    imgVectorAb = imgVectorLab(:,2:3);

    x = 1:2:150;
    accHistoAb = computeColorDistanceHistogram(imgVectorAb, x, nbIter, nbPixelsDistances);
    figAB = figure(4); bar(x, accHistoAb), xlim([0 max(x)]), title('AB distances histogram', 'FontSize', 18);

    % prepare the output file names
    [path, name] = fileparts(imFileName);
    rgbFilename = sprintf('%s_rgb.jpg', name);
    labFilename = sprintf('%s_lab.jpg', name);
    abFilename = sprintf('%s_ab.jpg', name);
    tdFilename = sprintf('%s_3d.jpg', name);

    % save all images to file
    imwrite(img, fullfile(outputDirJpg, imFileName));
    saveNiceFigure(figRGB, fullfile(outputDirJpg, rgbFilename));
    saveNiceFigure(figLAB, fullfile(outputDirJpg, labFilename));
    saveNiceFigure(figAB, fullfile(outputDirJpg, abFilename));
    saveNiceFigure(fig3D, fullfile(outputDirJpg, tdFilename));

    % title row
    cellArray(1,:) = {'Input image', 'RGB distance histogram', ...
        'LAB distance histogram', 'AB distance histogram', 'LAB 3-D plot'};

    % add a row to the cell array
    cellArray(2,:) = {...
        img2html(fullfile(outputDirJpg, imFileName), fullfile('jpg', imFileName), 'Width', 200), ...
        img2html(fullfile(outputDirJpg, rgbFilename), fullfile('jpg', rgbFilename), 'Width', 200), ...
        img2html(fullfile(outputDirJpg, labFilename), fullfile('jpg', labFilename), 'Width', 200), ...
        img2html(fullfile(outputDirJpg, abFilename), fullfile('jpg', abFilename), 'Width', 200), ...
        img2html(fullfile(outputDirJpg, tdFilename), fullfile('jpg', tdFilename), 'Width', 200), ...
        };

    % append to html
    cell2html(cellArray, outputHtmlFileName, ...
        'StandAlone', false, 'Caption', imFileName, ...
        'StyleClass', 'results', 'StyleSheet', '../../../style.css');

end

% write the footer
writeHtmlFooter(outputHtmlFileName);
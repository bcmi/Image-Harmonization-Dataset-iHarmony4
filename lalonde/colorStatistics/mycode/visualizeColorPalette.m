%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function visualizeColorPalette
%   Provides a way of visualizing the 2nd-order statistics by generating a palette of probable
%   colors given a set of input colors. We can then re-color an image using this palette.
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [palette2ndOrder, srcColor2ndOrder] = visualizeColorPalette 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup
addpath ../xml;
addpath ../histogram;
addpath ../../3rd_party/vgg_matlab/vgg_general;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox;

testImageXmlPath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/spatial_envelope_256x256_static_8outdoorcategories/';
fileName = 'coast_cdmc997_generated.xml';

% histogram paths
histoPath = '/nfs/hn01/jlalonde/results/colorStatistics/naturalSceneCategories/cumulHistogram/';
histoPath1stOrder = fullfile(histoPath, 'total1st.mat');
histoPath2ndOrder = fullfile(histoPath, 'total2nd.mat');

% load the histograms
total1stOrder = []; total2ndOrder = []; colorSpaces = [];
load(histoPath1stOrder);
load(histoPath2ndOrder);
% load('test.mat');
% total1stOrder{1} = hist1stOrder;
% total2ndOrder{1} = hist2ndOrder;
% total1stOrder{2} = hist1stOrder;
% total2ndOrder{2} = hist2ndOrder;

% Load the image
imgInfo = readStructFromXML(fullfile(testImageXmlPath, fileName));
origImg = imread(fullfile(testImageXmlPath, imgInfo.image.filename));
% figure, imshow(origImg);
% title('Original image');

% Number of colors to generate
nbColorsToGenerate = 1000;

nbBins1stOrder = 64;
nbBins2ndOrder = 16;

colorSpace = 'lab';

%% Convert color spaces (if needed)
if strcmp(colorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...');
    img = rgb2lab(origImg);

    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
elseif strcmp(colorSpace, 'rgb')
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
    
    img = origImg;
else
    error('Color Space %s unsupported!', colorSpace);
end

%% Prepare 1st-order statistics
colorSub = sampleFromHisto(total1stOrder{type}, nbColorsToGenerate);
deltas = (maxs-mins) / nbBins1stOrder;
generatedColors = repmat(mins, nbColorsToGenerate, 1) + repmat(deltas, nbColorsToGenerate, 1) .* ...
    colorSub - (repmat(deltas, nbColorsToGenerate, 1) ./ 2);

% Convert back to RGB
if strcmp(colorSpace, 'lab')
    generatedColors = lab2rgb(generatedColors) .* 255;
end

%% Display the colors
% figure; image(uint8(reshape(sortrows(generatedColors), 1, nbColorsToGenerate, 3)));
figure; image(uint8(reshape(generatedColors, 1, nbColorsToGenerate, 3)));
title('1st-order color palette');

%% Extract object information from image
% Make sure there's at least one object
% There should be only 1 object. We will always take the first either way.
objInd = 1;

% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(imgInfo.object(objInd).polygon);
objMask = poly2mask(xPoly, yPoly, size(origImg, 1), size(origImg, 2));

% compute the histogram of the object's color
histObj = imageHisto3D(img, objMask, nbBins2ndOrder, mins, maxs);
    
%% Randomly select a color from the object's distribution
tic
fprintf('Computing color palette of %d colors...', nbColorsToGenerate);
for c=1:nbColorsToGenerate
    % Get the corresponding histogram, and sample from it
    cumulHist2ndOrder = 0;
    while ~sum(cumulHist2ndOrder(:))
        % Sample a single color
        tmpColor = sampleFromHisto(histObj, 1);
    
        % Now look in the database for the corresponding histogram, and sample from it
        cumulHist2ndOrder = squeeze(total2ndOrder{type}(tmpColor(1), tmpColor(2), tmpColor(3), :, :, :));
    end
    
    % Sample from the resulting histogram
    generatedColors(c, :) = sampleFromHisto(cumulHist2ndOrder, 1);
end

deltas = (maxs-mins) / nbBins2ndOrder;
generatedColors = repmat(mins, nbColorsToGenerate, 1) + repmat(deltas, nbColorsToGenerate, 1) .* ...
    generatedColors - (repmat(deltas, nbColorsToGenerate, 1) ./ 2);
fprintf('done in %.2f seconds!\n', toc);

% Convert back to RGB
if strcmp(colorSpace, 'lab')
    generatedColors = lab2rgb(generatedColors) .* 255;
%     srcColor2ndOrder = lab2rgb(srcColor2ndOrder) .*255;
end

%% Display the color palette
palette2ndOrder = generatedColors;
% figure; image(uint8(reshape(sortrows(palette2ndOrder), 1, nbColorsToGenerate, 3)));
figure; image(uint8(reshape(palette2ndOrder, 1, nbColorsToGenerate, 3)));
title('2nd-order color palette');
fprintf('Done!\n');

%% Display the randomly chosen colors from the object
% figure; image(uint8(reshape(srcColor2ndOrder, 1, nbColorsToGenerate, 3)));
% title('Colors sampled from the object');
% fprintf('Done!\n');


%% Re-color the input image
imgColors = reshape(origImg, size(origImg,1)*size(origImg,2), 3);
[inds, d2] = vgg_nearest_neighbour(double(imgColors'), double(palette2ndOrder'));

imgRecolored = reshape(palette2ndOrder(inds,:), size(origImg,1), size(origImg,2), 3);
% figure; imshow(uint8(imgRecolored));
% title('Re-colored image according to palette predicted by pasted object');

imgMontage = zeros(size(origImg, 1), size(origImg, 2), 3, 2, 'uint8');
imgMontage(:,:,:,1) = uint8(origImg);
imgMontage(:,:,:,2) = uint8(imgRecolored);

montage(imgMontage);

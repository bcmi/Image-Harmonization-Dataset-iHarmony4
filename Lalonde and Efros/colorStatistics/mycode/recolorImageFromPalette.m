%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function recolorImageFromPalette
%   Provides a way of visualizing the 2nd-order statistics by generating a palette of probable
%   colors given a set of input colors. We can then re-color an image using this palette.
% 
% Input parameters:
%
% Output parameters:
%   - h: handle to the graphical object created (montage)
%   - imgInfo: 
%   - nbColors: Number of colors to use in palette. Can be a
%     vector of size [N x 1], will generate N images
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = recolorImageFromPalette(origImg, imgInfo, nbColors, histo1stOrder, histo2ndOrder, colorSpace) 
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

nbBins1stOrder = size(histo1stOrder, 1);
nbBins2ndOrder = size(histo2ndOrder, 2);

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

%% Extract object information from image
% Make sure there's at least one object
% There should be only 1 object. We will always take the first either way.
objInd = 1;

% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(imgInfo.object(objInd).polygon);
objMask = poly2mask(xPoly, yPoly, size(origImg, 1), size(origImg, 2));

% compute the histogram of the object's color
histObj = imageHisto3D(img, objMask, nbBins2ndOrder, mins, maxs);

nbIter = length(nbColors);
imgMontage = zeros(size(origImg, 1), size(origImg, 2), 3, nbIter+2, 'uint8');
imgMontage(:,:,:,1) = uint8(origImg);

for n=1:nbIter
    nbColorsToGenerate = nbColors(n);
    
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
            cumulHist2ndOrder = squeeze(histo2ndOrder(tmpColor(1), tmpColor(2), tmpColor(3), :, :, :));
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
    end

    %% Re-color the input image
    fprintf('Recoloring image...'); tic;
    imgColors = reshape(origImg, size(origImg,1)*size(origImg,2), 3);
    
    [inds, d2] = vgg_nearest_neighbour(double(imgColors'), double(generatedColors'));
    imgRecolored = reshape(generatedColors(inds,:), size(origImg,1), size(origImg,2), 3);
    fprintf('done in %.2f seconds!\n', toc);
    
    imgMontage(:,:,:,n+2) = uint8(imgRecolored);
end

[x,y,z] = meshgrid(1:nbBins2ndOrder, 1:nbBins2ndOrder, 1:nbBins2ndOrder);
allColors = [y(:) x(:) z(:)];
deltas = (maxs-mins) / nbBins2ndOrder;
allColors = repmat(mins, size(allColors,1), 1) + repmat(deltas, size(allColors,1), 1) .* ...
    allColors - (repmat(deltas, size(allColors,1), 1) ./ 2);
if strcmp(colorSpace, 'lab')
    allColors = lab2rgb(allColors).*255;
end

fprintf('Quantizing the original image...'); tic;
imgColors = reshape(origImg, size(origImg,1)*size(origImg,2), 3);
[inds, d2] = vgg_nearest_neighbour(double(imgColors'), double(allColors'));
imgQuantized = reshape(allColors(inds,:), size(origImg,1), size(origImg,2), 3);
imgMontage(:,:,:,2) = uint8(imgQuantized);
fprintf('done in %.2f seconds!\n', toc);

% draw the object's outlines on the second image
xPoly = [xPoly; xPoly(1)];
yPoly = [yPoly; yPoly(1)];

xPoly = xPoly + size(origImg, 1);
h = montage(imgMontage); hold on;
line(xPoly, yPoly, 'LineWidth', 2);
set(gca, 'Position', [0 0 1 1]);


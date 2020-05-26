% function testCombinationScore
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup path and load stuff
addpath ../;
setPath;

close all;
basePath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/filteredDb';
dbPath = fullfile(basePath, 'Annotation');
imagesPath = fullfile(basePath, 'Images');

% testImage = 'image_002361';
% testImage = 'image_007804';
testImage = 'image_007972';
% testImage = 'image_007970';
% testImage = 'image_007969';
% testImage = 'image_007964';
% testImage = 'image_007949';

imagePath = fullfile(imagesPath, sprintf('%s.jpg', testImage));
annotationPath = fullfile(dbPath, sprintf('%s.xml', testImage));

% Load the masks
imgInfo = loadXML(annotationPath);
load(fullfile(dbPath, imgInfo.object.masks.filename));

rgbImage = double(imread(imagePath));
grayImage = mean(double(rgbImage), 3);
labImage = rgb2lab(rgbImage);
hsvImage = rgb2hsv(rgbImage);
% chromaImage(:,:,1) = (rgbImage(:,:,1) ./ rgbImage(:,:,2)) .^ (1/3);
% chromaImage(:,:,2) = (rgbImage(:,:,3) ./ rgbImage(:,:,2)) .^ (1/3);

[h,w,c] = size(rgbImage);

% Load the texton weight
textonDistPath = fullfile(dbPath, imgInfo.file.folder, imgInfo.local.textonMatching.filename);
textonDist = imresize(imread(textonDistPath), [h w], 'bilinear');
textonDist = double(textonDist) ./ 255; % normalize
textonDist(bgMask == 0) = 1;
textonWeight = ones(size(textonDist)) - textonDist;


%% Try with the lab image
% img = chromaImage;
% img = labImage(:,:,2:3);
img = labImage;
% img = hsvImage(:,:,1:2);

imgVector = reshape(img, [w*h c]);
colorsVector = reshape(rgbImage, [w*h 3]);

% Retrieve the background and object pixels
bgPixels = double(imgVector(bgMask(:), :));
objPixels = double(imgVector(objMask(:), :));

%% Compute signatures
nbClusters = 100;
[centersObj, weightsObj, indsObj] = signaturesKmeans(objPixels, nbClusters);
[centersBg, weightsBg, indsBg] = signaturesKmeans(bgPixels, nbClusters);
% signatureFig = figure(3); hold on;
% plotSignatures(signatureFig, centersObj, weightsObj, 'lab');
% plotSignatures(signatureFig, centersBg, weightsBg, 'lab');
% title(sprintf('K-means clustering with k=%d on image colors', nbClusters));
% figure(4), displayColors(imgVector, colorsVector), title('Original image colors');

%% Compute the EMD between signatures
distMat = pdist2(centersObj', centersBg');
weightsBgTextons = reweightClustersFromTextons(weightsBg, textonWeight(bgMask(:)), indsBg);
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBgTextons', distMat);

emdFig = figure(10); hold on;
plotEMD(emdFig, centersObj, centersBg, flowEMD);
plotSignatures(emdFig, centersObj, weightsObj, 'lab');
plotSignatures(emdFig, centersBg, weightsBg, 'lab');
title(sprintf('K-means clustering with k=%d on image colors, EMD=%f', nbClusters, distEMD));
xlabel('l'), ylabel('a'), zlabel('b');
drawnow;

%% Get the mean/median pixel shift for different values of sigma
sigmas = 5:5:100;
% sigmas = 5;
means = zeros(length(sigmas), 1);
medians = zeros(length(sigmas), 1);
pctDist = zeros(length(sigmas), 1);
pctDistW = zeros(length(sigmas), 1);
montageImg = zeros(size(img,1), size(img,2), 3, length(sigmas), 'uint8');
for sigma=sigmas
    disp(sigma);
    [imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = recolorImageFromEMD(centersBg, centersObj, img,  indsObj, find(objMask(:)), flowEMD, sigma);
    
    clusterShiftWeightMax = max(clusterShiftWeight, [], 2);
    pctDist(sigmas==sigma) = nnz(clusterShiftWeightMax<0.5) / length(clusterShiftWeightMax);
    pctDistW(sigmas==sigma) = sum(clusterShiftWeightMax .* weightsObj);
    
    montageImg(:,:,:,sigmas==sigma) = lab2rgb(imgTgtNNW);
    means(sigmas==sigma) = mean(sqrt(sum(pixelShift.^2, 2)));
    medians(sigmas==sigma) = median(sqrt(sum(pixelShift.^2, 2)));
end

t = 0.9;
% linearly interpolate to find sigma
bestSigma = interp1(pctDistW, sigmas, t);
if isnan(bestSigma)
    bestSigma = 0;
end

figure(1), montage(montageImg);
figure(2), plot(sigmas, means), hold on, plot(sigmas, sigmas, 'r'), xlabel('\sigma'), ylabel('Mean pixel shift')
figure(3), plot(sigmas, pctDist), xlabel('\sigma'), ylabel('% of shift less than 0.5')
figure(4), plot(sigmas, pctDistW), xlabel('\sigma'), ylabel('% of shift'), title(sprintf('\\sigma = %.2f', bestSigma));

%% Show the image with the best sigma
[imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = recolorImageFromEMD(centersBg, centersObj, img,  indsObj, find(objMask(:)), flowEMD, bestSigma);
figure(5), subplot(1,2,1), imshow(uint8(rgbImage)), title(sprintf('\\sigma = %.2f', 0)), ...
    subplot(1,2,2), imshow(lab2rgb(imgTgtNNW)), title(sprintf('\\sigma = %.2f', bestSigma));

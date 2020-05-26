function testRecoloring
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
testImage = 'image_007804';

sigma = 12;

imagePath = fullfile(imagesPath, sprintf('%s.jpg', testImage));
annotationPath = fullfile(dbPath, sprintf('%s.xml', testImage));

% Load the masks
imgInfo = loadXML(annotationPath);
load(fullfile(dbPath, imgInfo.object.masks.filename));

rgbImage = double(imread(imagePath));
grayImage = mean(double(rgbImage), 3);
labImage = rgb2lab(rgbImage);
hsvImage = rgb2hsv(rgbImage);
chromaImage(:,:,1) = (rgbImage(:,:,1) ./ rgbImage(:,:,2)) .^ (1/3);
chromaImage(:,:,2) = (rgbImage(:,:,3) ./ rgbImage(:,:,2)) .^ (1/3);
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
nbClusters = 50;
[centersObj, weightsObj, indsObj] = signaturesKmeans(objPixels, nbClusters);
[centersBg, weightsBg, indsBg] = signaturesKmeans(bgPixels, nbClusters);
% signatureFig = figure(3); hold on;
% plotSignatures(signatureFig, centersObj, weightsObj, 'lab');
% plotSignatures(signatureFig, centersBg, weightsBg, 'lab');
% title(sprintf('K-means clustering with k=%d on image colors', nbClusters));
% figure(4), displayColors(imgVector, colorsVector), title('Original image colors');

%% Compute the EMD between signatures
distMat = pdist2(centersObj', centersBg');
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBg', distMat);

emdFig = figure(4); hold on;
plotEMD(emdFig, centersObj, centersBg, flowEMD);
plotSignatures(emdFig, centersObj, weightsObj, 'lab');
plotSignatures(emdFig, centersBg, weightsBg, 'lab');
title(sprintf('K-means clustering with k=%d on image colors, EMD=%f', nbClusters, distEMD));
xlabel('l'), ylabel('a'), zlabel('b');

%% Weight each background clusters by its texton matching to the object
weightsBgTextons = reweightClustersFromTextons(weightsBg, textonWeight(bgMask(:)), indsBg);

% re-compute the EMD with the texton-weighted clusters
[distEMD, flowEMDTextons] = emd_mex(weightsObj', weightsBgTextons', distMat);

emdFig = figure(5); hold on;
plotEMD(emdFig, centersObj, centersBg, flowEMDTextons);
plotSignatures(emdFig, centersObj, weightsObj, 'lab');
plotSignatures(emdFig, centersBg, weightsBgTextons, 'lab');
title(sprintf('EMD with weighted clusters with k=%d on image colors, EMD=%f', nbClusters, distEMD));
xlabel('l'), ylabel('a'), zlabel('b');

%% Recolor
sigma = 5;
[imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = ...
    recolorImageFromEMD(centersBg, centersObj, img, indsObj, find(objMask(:)), flowEMD, sigma);

figure(7), subplot(1,2,1), imshow(uint8(rgbImage)), title('Original image'), ...
    subplot(1,2,2), imshow(lab2rgb(imgTgtNNW)), title(sprintf('Weighted nn cluster center, \\sigma=%d', sigma));

clusterShiftWeightMax = max(clusterShiftWeight, [], 2);
pctDist(sigmas==sigma) = nnz(clusterShiftWeightMax<0.5) / length(clusterShiftWeightMax);

%% Recolor with texton weighting
sigma = 5;
[imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = ...
    recolorImageFromEMD(centersBg, centersObj, img, indsObj, find(objMask(:)), flowEMDTextons, sigma);

figure(8), subplot(1,2,1), imshow(uint8(rgbImage)), title('Original image'), ...
    subplot(1,2,2), imshow(lab2rgb(imgTgtNNW)), title(sprintf('Weighted nn cluster center (textons), \\sigma=%d', sigma));

clusterShiftWeightMax = max(clusterShiftWeight, [], 2);
pctDist(sigmas==sigma) = nnz(clusterShiftWeightMax<0.5) / length(clusterShiftWeightMax);

return;

%% Determine the cluster shift (want to map the object's color to the background's)
clusterShift = zeros(length(centersObj), 3);
for c=1:length(centersObj)
    dstClusters = flowEMD(flowEMD(:,1) == c, 2);
    weights = flowEMD(flowEMD(:,1) == c, 3);
    
    shifts = centersBg(dstClusters, :) - repmat(centersObj(c, :), [length(dstClusters) 1]);
    clusterShift(c,:) = sum(shifts .* repmat(weights, [1 3]), 1) ./ sum(weights);
    
    % gaussian kernel on the distance (far distances are less important)
    clusterShift(c,:) = clusterShift(c,:) .* min(exp(-abs(clusterShift(c,:)).^2./(sigma.^2)), abs(clusterShift(c,:)) < sigma);
end

%% Determine each pixel's shift. First try the nearest-neighbor cluster center
imgVectorNN = imgVector;
pixelShift = clusterShift(indsObj,:);
imgVectorNN(objMask(:),:) = imgVectorNN(objMask(:),:) + pixelShift;

imgNN = reshape(imgVectorNN, [h w 3]);
rgbImageNN = lab2rgb(imgNN);

%% Determine each pixel's shift. Weight by inverse distance to N cluster centers
K = round(nbClusters / 2);
% find the K-nearest neighbor cluster center for each pixel
D = pdist2(imgVector(objMask(:), :)', centersObj');
[sortedD, sortedInd] = sort(D,2);
clusterNeighbors = sortedInd(:,1:K);

% compute distances from each pixel to each nearest neighbor cluster center
objPixelsMat = repmat(objPixels, [1 1 K]);
centersObjMat = permute(reshape(centersObj(clusterNeighbors,:), [nnz(objMask) K 3]), [1 3 2]);
distClusters = mysqueeze(sqrt(sum((objPixelsMat - centersObjMat) .^ 2, 2)));

% weight each distance by gaussian (normalized)
weightClusters = min(exp(-distClusters.^2./sigma.^2), distClusters < sigma);
normFactor = repmat(sum(weightClusters, 2), [1 K]);
normFactor(normFactor == 0) = 1;
weightClusters = weightClusters ./ normFactor;

% pixel shift is weighted combination of cluster shifts
pixelShift = permute(reshape(clusterShift(clusterNeighbors, :), [nnz(objMask) K 3]), [1 3 2]);
shiftWeight = repmat(permute(weightClusters, [1 3 2]), [1 3 1]);
pixelShift = sum(pixelShift .* shiftWeight, 3);


%% Re-color
imgVectorNNW = imgVector;
imgVectorNNW(objMask(:),:) = imgVectorNNW(objMask(:),:) + pixelShift;

imgNNW = reshape(imgVectorNNW, [h w 3]);
rgbImageNNW = lab2rgb(imgNNW);
figure(7), subplot(1,3,1), imshow(uint8(rgbImage)), title('Original image'), ...
    subplot(1,3,2), imshow(rgbImageNN), title('nn cluster center'), ...
    subplot(1,3,3), imshow(rgbImageNNW), title('Weighted nn cluster center');

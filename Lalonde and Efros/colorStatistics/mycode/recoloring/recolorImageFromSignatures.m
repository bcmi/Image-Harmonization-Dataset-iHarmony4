%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [imgTgtNN, imgTgtNNW, centersSrc, weightsSrc, centersTgt, weightsTgt, flowEMD, pixelShift] = 
%  recolorImageFromSignatures(imgSrc, imgTgt, indSrc, indTgt)
%   Recolors an image by computing color shifts from its signatures.
% 
% Input parameters:
%   - imgSrc: source image 
%   - imgTgt: target image (to recolor)
%   - indSrc: indices of pixels in source image to use
%   - indTgt: indices of pixels in target image to use
%
% Output parameters:
%   - recoloredTgt: recolored image
% 
% Notes:
%   - the input images *must* be in RGB space, and LAB space is used for the coloring. 
% 
% Todo: 
%   - add support for different color spaces -> need to find good sigma?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imgTgtNN, imgTgtNNW, centersSrc, weightsSrc, centersTgt, weightsTgt, flowEMD, pixelShift] = ...
    recolorImageFromSignatures(imgSrc, imgTgt, indSrc, indTgt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sigma = 25;

% convert the images to Lab
imgSrcLab = rgb2lab(imgSrc);
imgTgtLab = rgb2lab(imgTgt);

%% Try with the lab image
imgSrcVector = reshape(imgSrcLab, [size(imgSrc,1)*size(imgSrc,2) size(imgSrc,3)]);
imgTgtVector = reshape(imgTgtLab, [size(imgTgt,1)*size(imgTgt,2) size(imgTgt,3)]);

% Retrieve the background and object pixels
srcPixels = double(imgSrcVector(indSrc, :));
tgtPixels = double(imgTgtVector(indTgt, :));

%% Compute signatures
nbClusters = 50;
[centersSrc, weightsSrc] = signaturesKmeans(srcPixels, nbClusters);
[centersTgt, weightsTgt, indsTgt] = signaturesKmeans(tgtPixels, nbClusters);

%% Compute the EMD between signatures
distMat = pdist2(centersTgt', centersSrc');
[distEMD, flowEMD] = emd_mex(weightsTgt', weightsSrc', distMat);

%% Determine the cluster shift (want to map the object's color to the background's)
clusterShift = zeros(length(centersTgt), 3);
for c=1:length(centersTgt)
    dstClusters = flowEMD(flowEMD(:,1) == c, 2);
    weights = flowEMD(flowEMD(:,1) == c, 3);
    
    shifts = centersSrc(dstClusters, :) - repmat(centersTgt(c, :), [length(dstClusters) 1]);
    clusterShift(c,:) = sum(shifts .* repmat(weights, [1 3]), 1) ./ sum(weights);
    
    % gaussian kernel on the distance (far distances are less important)
    clusterShift(c,:) = clusterShift(c,:) .* min(exp(-abs(clusterShift(c,:)).^2./(sigma.^2)), abs(clusterShift(c,:)) < sigma);
%     clusterShift(c,:) = clusterShift(c,:) .* exp(-abs(clusterShift(c,:)).^2./(sigma.^2));
end

%% Determine each pixel's shift. First try the nearest-neighbor cluster center
imgVectorNN = imgTgtVector;
pixelShift = clusterShift(indsTgt,:);
imgVectorNN(indTgt,:) = imgVectorNN(indTgt,:) + pixelShift;

imgNN = reshape(imgVectorNN, [size(imgTgt,1) size(imgTgt,2) size(imgTgt,3)]);
imgTgtNN = lab2rgb(imgNN);

%% Determine each pixel's shift. Weight by inverse distance to N cluster centers
K = round(nbClusters / 2);
% find the K-nearest neighbor cluster center for each pixel
D = pdist2(imgTgtVector(indTgt, :)', centersTgt');
[sortedD, sortedInd] = sort(D,2);
clusterNeighbors = sortedInd(:,1:K);

% compute distances from each pixel to each nearest neighbor cluster center
tgtPixelsMat = repmat(tgtPixels, [1 1 K]);
centersTgtMat = permute(reshape(centersTgt(clusterNeighbors,:), [length(indTgt) K 3]), [1 3 2]);
distClusters = mysqueeze(sqrt(sum((tgtPixelsMat - centersTgtMat) .^ 2, 2)));

% weight each distance by gaussian (normalized)
weightClusters = exp(-distClusters.^2./sigma.^2);
normFactor = repmat(sum(weightClusters, 2), [1 K]);
normFactor(normFactor == 0) = 1;
weightClusters = weightClusters ./ normFactor;

% pixel shift is weighted combination of cluster shifts
pixelShift = permute(reshape(clusterShift(clusterNeighbors, :), [length(indTgt) K 3]), [1 3 2]);
shiftWeight = repmat(permute(weightClusters, [1 3 2]), [1 3 1]);
pixelShift = sum(pixelShift .* shiftWeight, 3);

%% Re-color
imgVectorNNW = imgTgtVector;
imgVectorNNW(indTgt,:) = imgVectorNNW(indTgt,:) + pixelShift;

imgNNW = reshape(imgVectorNNW, [size(imgTgt,1) size(imgTgt,2) size(imgTgt,3)]);
imgTgtNNW = lab2rgb(imgNNW);

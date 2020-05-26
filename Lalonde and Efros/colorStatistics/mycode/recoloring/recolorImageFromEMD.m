%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [imgTgtNN, imgTgtNNW, pixelShift] = recolorImageFromEMD(centersSrc, centersTgt, flowEMD, sigma)
%   Recolors an image by computing color shifts from its signatures.
% 
% Input parameters:
%
% Output parameters:
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = recolorImageFromEMD(centersSrc, centersTgt, imgTgt, indsClusterTgt, indPixelsTgt, flowEMD, sigma)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Determine the cluster shift (want to map the object's color to the background's)
clusterShift = zeros(length(centersTgt), 3);
for c=1:length(centersTgt)
    dstClusters = flowEMD(flowEMD(:,1) == c, 2);
    weights = flowEMD(flowEMD(:,1) == c, 3);
    
    shifts = centersSrc(dstClusters, :) - repmat(centersTgt(c, :), [length(dstClusters) 1]);
    clusterShift(c,:) = sum(shifts .* repmat(weights, [1 3]), 1) ./ sum(weights);
end
% truncated gaussian kernel on the distance (far distances are less important, up to a hard threshold)
clusterShiftWeight = min(exp(-abs(clusterShift).^2./(sigma.^2)), abs(clusterShift) < sigma);
clusterShiftWeightT = abs(clusterShift) < sigma;

clusterShift = clusterShift .* clusterShiftWeight;

%% Determine each pixel's shift. First try the nearest-neighbor cluster center
imgTgtVector = reshape(imgTgt, [size(imgTgt, 1)*size(imgTgt,2), size(imgTgt,3)]);
imgVectorNN = imgTgtVector;
pixelShift = clusterShift(indsClusterTgt,:);
imgVectorNN(indPixelsTgt,:) = imgVectorNN(indPixelsTgt,:) + pixelShift;

imgTgtNN = reshape(imgVectorNN, [size(imgTgt,1) size(imgTgt,2) size(imgTgt,3)]);

%% Determine each pixel's shift. Weight by inverse distance to N cluster centers
nbClusters = length(unique(indsClusterTgt));
K = round(nbClusters / 2);
% find the K-nearest neighbor cluster center for each pixel
D = pdist2(imgTgtVector(indPixelsTgt, :), centersTgt);
[sortedD, sortedInd] = sort(D,2);
clusterNeighbors = sortedInd(:,1:K);

% compute distances from each pixel to each nearest neighbor cluster center
tgtPixels = imgTgtVector(indPixelsTgt, :);
tgtPixelsMat = repmat(tgtPixels, [1 1 K]);
centersTgtMat = permute(reshape(centersTgt(clusterNeighbors,:), [length(indPixelsTgt) K 3]), [1 3 2]);
distClusters = squeeze(sqrt(sum((tgtPixelsMat - centersTgtMat) .^ 2, 2)));

% weight each distance by gaussian (normalized)
weightClusters = exp(-distClusters.^2./sigma.^2);
normFactor = repmat(sum(weightClusters, 2), [1 K]);
normFactor(normFactor == 0) = 1;
weightClusters = weightClusters ./ normFactor;

% pixel shift is weighted combination of cluster shifts
pixelShift = permute(reshape(clusterShift(clusterNeighbors, :), [length(indPixelsTgt) K 3]), [1 3 2]);
shiftWeight = repmat(permute(weightClusters, [1 3 2]), [1 3 1]);
pixelShift = sum(pixelShift .* shiftWeight, 3);

%% Re-color (assuming the input is in lab colorspace)
imgVectorNNW = imgTgtVector;
imgVectorNNW(indPixelsTgt,:) = imgVectorNNW(indPixelsTgt,:) + pixelShift;

imgTgtNNW = reshape(imgVectorNNW, [size(imgTgt,1) size(imgTgt,2) size(imgTgt,3)]);

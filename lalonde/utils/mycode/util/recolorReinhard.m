%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [outPixels, meanDiff, stdRatio] = recolorReinhard(srcPixels, tgtPixels, doLab, alphaMean, alphaVar)
%   Recolors an object put inside an image according to the recoloring technique by Reinhard et al.
%   Lab space used instead of original L-alpha-beta color space
% 
% Input parameters:
%
%   - srcPixels: Object's pixels (RGB, Mx3)
%   - tgtPixels: Background's pixels, (RGB, Nx3)
%
% Output parameters:
%
%   - outPixels: the source pixels recolored according to Reinhard's technique.
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outPixels, meanDiff, stdRatio] = recolorReinhard(srcPixels, tgtPixels, doLab, alphaMean, alphaVar)

if nargin < 3
    % default: use Lab
    doLab = 1;
    alphaMean = 1;
    alphaVar = 1;
end

%% Color space and reshape
if doLab
    [L,a,b] = rgb2lab(srcPixels(:,1), srcPixels(:,2), srcPixels(:,3)); srcPixels = [L(:) a(:) b(:)];
    [L,a,b] = rgb2lab(tgtPixels(:,1), tgtPixels(:,2), tgtPixels(:,3)); tgtPixels = [L(:) a(:) b(:)];
end

nbSrcPixels = size(srcPixels, 1);

%% Compute mean and stdev of object and background
tgtMean = mean(tgtPixels);
tgtStd = std(tgtPixels);

srcMean = mean(srcPixels);
srcStd = std(srcPixels);

meanDiff = tgtMean - srcMean;
stdRatio = tgtStd./srcStd;
% stdRatio = [1 1 1];

%% Recolor by matching the distributions
% outPixels = (srcPixels - repmat(srcMean, [nbSrcPixels 1]))  .* repmat(stdRatio, [nbSrcPixels 1]) + repmat(tgtMean, [nbSrcPixels 1]);

%% Test
% match variances (not completely)
outPixels = (srcPixels - repmat(srcMean, [nbSrcPixels 1])) .* alphaVar.*repmat(stdRatio, [nbSrcPixels 1]) + repmat(srcMean, [nbSrcPixels 1]);

% move towards mean (but not completely)
outPixels = outPixels + alphaMean.*repmat(meanDiff, [nbSrcPixels 1]);
%% Convert back to RGB
if doLab
    [R,G,B] = lab2rgb(outPixels(:,1), outPixels(:,2), outPixels(:,3));
    outPixels = cat(2, R,G,B);
end
function [score, indBestMatch, bgDist] = computeGlobalRealismScore(...
    colorConcatHistPath, textonConcatHistPath, ...
    colorObjHist, textonObjHist, colorBgHist, textonBgHist, alpha, k)
% Computes the global realsim score based on a large database of images
%
%   [score, indNearestNeighbor] = computeGlobalRealismScore(...
%       colorConcatHistPath, textonConcatHistPath, colorHist, textonHist, ...
%       type, alpha, k)
%
%   - type can be either 'Obj' or 'Bg'
%   - alpha must be between 0 and 1 and represents the blend between color
%   and texture information.
%   - k is the number of nearest neighbor to use

% Compute object matches
objDist = computeGlobalDistanceMeasure(...
    colorConcatHistPath, textonConcatHistPath, ...
    colorObjHist, textonObjHist, 'Obj', alpha);

% Find k-nearest neighbors
[s,sind] = sort(objDist);
indNearestNeighbor = sind(1:k);

% Compute background matches (this isn't terribly efficient because we're
% effectively computing it on the entire database, whereas we only need to
% do it on the k-nearest neighbors... but right now, that's the fastest 
% implementation route, sorry!)
bgDist = computeGlobalDistanceMeasure(...
    colorConcatHistPath, textonConcatHistPath, ...
    colorBgHist, textonBgHist, 'Bg', alpha);

[score, mind] = min(bgDist(indNearestNeighbor));
indBestMatch = indNearestNeighbor(mind);

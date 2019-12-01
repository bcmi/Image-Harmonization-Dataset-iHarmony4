%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingLocalObjectDb
%   Evaluate the matching of a test image based on different local measures (which don't require the
%   use of global statistics)
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnEvaluateMatchingLocalObjectDb(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;
nbBins = 100;
imgWidth = 256;

% read arguments
defaultArgs = struct('ColorSpace', [], 'DbPath', []);
args = parseargs(defaultArgs, varargin{:});

xmlPath = fullfile(outputBasePath, annotation.file.folder);
[m,m,m] = mkdir(xmlPath);
xmlPath = fullfile(xmlPath, annotation.file.filename);

if exist(xmlPath, 'file')
    imgInfo = loadXML(xmlPath);
else
    imgInfo.image = annotation.image;
    imgInfo.file = annotation.file;
end

filterVariance = 1;

if strcmp(args.ColorSpace, 'lab')
    type = 1;
    
    % smooth equally in all dimensions
    h = myGaussian3(floor(nbBins/10), filterVariance);
  
elseif strcmp(args.ColorSpace, 'rgb')
    type = 2;
    % smooth equally in all dimensions
    h = myGaussian3(floor(nbBins/10), filterVariance);

elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    type = 3;
    
    % smooth more in S
    h = myGaussian3(floor(nbBins/10), diag([filterVariance filterVariance*2 filterVariance]));
elseif strcmp(args.ColorSpace, 'lalphabeta')
    % convert the image to the l-alpha-beta color space
    type = 4;
    
    % smooth equally in all dimensions
    h = myGaussian3(floor(nbBins/10), filterVariance);
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.localEval(type).colorSpace = args.ColorSpace;

% read the histograms
histoPath = fullfile(args.DbPath, annotation.file.folder, annotation.histograms(type).filename);
load(histoPath);

%% Compute the joint statistics
fprintf('Computing the joint...');
histObjJoint = jointObjHisto; %# ok
histObjJointNorm = histObjJoint ./ sum(histObjJoint(:));

histBgDstJoint = jointBgHisto; %# ok
histBgDstJointNorm = histBgDstJoint ./ sum(histBgDstJoint(:));

histBgDstJointWeighted = histBgDstJoint .* histObjJointNorm;
if ~sum(histBgDstJointWeighted(:))
    overlapDst = 0;
    histBgDstJointWeightedNorm = [];
else
    histBgDstJointWeightedNorm = histBgDstJointWeighted ./ sum(histBgDstJointWeighted(:));
    overlapDst = 1;
end

% smooth the object's histogram
fprintf('Smoothing...');
histObjJointSmooth = convn(histObjJointNorm, h, 'same');

histBgDstJointWeightedSmooth = histBgDstJoint .* histObjJointSmooth;
if ~sum(histBgDstJointWeightedSmooth(:))
    overlapDstSmooth = 0;
    histBgDstJointWeightedSmoothNorm = [];
else
    histBgDstJointWeightedSmoothNorm = histBgDstJointWeightedSmooth ./ sum(histBgDstJointWeightedSmooth(:));
    overlapDstSmooth = 1;
end

%% Try all local measures
% Obj and BgDst
imgInfo = setFieldDist(imgInfo, type, 'objBgDst', 'joint', 1, ...
    histObjJointNorm, histBgDstJointNorm, 1, nbBins);

% Obj and BgDst(Obj)
imgInfo = setFieldDist(imgInfo, type, 'objBgDstW', 'joint', 1, ...
    histObjJointNorm, histBgDstJointWeightedNorm, overlapDst, nbBins);

% Obj and BgDstSmooth(Obj)
imgInfo = setFieldDist(imgInfo, type, 'objBgDstWS', 'joint', 1, ...
    histObjJointNorm, histBgDstJointWeightedSmoothNorm, overlapDstSmooth, nbBins);

%% Compute the marginals 
fprintf('Computing the marginals...');
for c=1:3
    histObj = squeeze(sum(sum(histObjJoint, mod(c,3)+1), mod(c+1,3)+1));
    histObjNorm = histObj ./ sum(histObj(:));
    
    histBgDst = squeeze(sum(sum(histBgDstJoint, mod(c,3)+1), mod(c+1,3)+1));
    histBgDstNorm = histBgDst ./ sum(histBgDst(:));

    histBgDstWeighted = histBgDst .* histObjNorm;
    if ~sum(histBgDstWeighted(:))
        overlapDst = 0;
        histBgDstWeightedNorm = [];
    else
        histBgDstWeightedNorm = histBgDstWeighted ./ sum(histBgDstWeighted(:));
        overlapDst = 1;
    end
        
    % Smoothed version
    histBgDstWeightedSmooth = histBgDst .* squeeze(sum(sum(histObjJointSmooth, mod(c,3)+1), mod(c+1,3)+1));
    if ~sum(histBgDstWeightedSmooth(:))
        overlapDstSmooth = 0;
        histBgDstWeightedSmoothNorm = [];
    else
        histBgDstWeightedSmoothNorm = histBgDstWeightedSmooth ./ sum(histBgDstWeightedSmooth(:));
        overlapDstSmooth = 1;
    end

    % Obj and BgDst
    imgInfo = setFieldDist(imgInfo, type, 'objBgDst', 'marginal', c, ...
        histObjNorm, histBgDstNorm, 1, nbBins);

    % Obj and BgDst(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'objBgDstW', 'marginal', c, ...
        histObjNorm, histBgDstWeightedNorm, overlapDst, nbBins);

    % Obj and BgDstSmooth(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'objBgDstWS', 'marginal', c, ...
        histObjNorm, histBgDstWeightedSmoothNorm, overlapDstSmooth, nbBins);
end
fprintf('done!\n');


%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

%% Useful function
function imgInfo = setFieldDist(imgInfo, type, fieldName, subFieldName, c, hist1, hist2, overlap, nbBins)

imgInfo.localEval(type).(fieldName).nbBins = nbBins;
if overlap
    imgInfo.localEval(type).(fieldName).(subFieldName)(c).distChi = chisq(hist1, hist2);
    imgInfo.localEval(type).(fieldName).(subFieldName)(c).distDot = hist1(:)' * hist2(:);
else
    % unknown if there's no overlap
%     imgInfo.localEval(type).(fieldName).(subFieldName)(c).distChi = 0;
%     imgInfo.localEval(type).(fieldName).(subFieldName)(c).distDot = 1;
    imgInfo.localEval(type).(fieldName).(subFieldName)(c).distChi = -1;
    imgInfo.localEval(type).(fieldName).(subFieldName)(c).distDot = -1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingLocal
%   Evaluate the matching of a test image based on different local measures (which don't require the
%   use of global statistics)
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnEvaluateMatchingLocal(outputBasePath, annotation, varargin) 
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
defaultArgs = struct('ColorSpace', [], 'DbPath', [], 'ImagesPath', [], ...
    'SubsampledImagesPath', [], 'ObjectDbPath', []);
args = parseargs(defaultArgs, varargin{:});

% read the source image
objImgPath = fullfile(args.SubsampledImagesPath, annotation.objImgSrc.folder, annotation.objImgSrc.filename);
imgSrc = imresize(imread(objImgPath), [imgWidth imgWidth], 'bilinear');

bgImgPath = fullfile(args.SubsampledImagesPath, annotation.bgImgSrc.folder, annotation.bgImgSrc.filename);
imgDst = imresize(imread(bgImgPath), [imgWidth imgWidth], 'bilinear');

% read the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename));

[pathstr, file] = fileparts(annotation.objImgSrc.filename);
objInfoPath = fullfile(args.ObjectDbPath, annotation.objImgSrc.folder, sprintf('%s_%04d.xml', file, str2double(annotation.object.objectId)));
objInfo = loadXML(objInfoPath);

outXmlPath = fullfile(outputBasePath, annotation.file.folder);
[m,m,m] = mkdir(outXmlPath); %#ok
xmlPath = fullfile(outXmlPath, annotation.file.filename);

if exist(xmlPath, 'file')
    imgInfo = loadXML(xmlPath);
else
    imgInfo.image = annotation.image;
    imgInfo.file = annotation.file;
end

filterVariance = 1;

if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...\n');
    imgSrc = rgb2lab(imgSrc);
    imgDst = rgb2lab(imgDst);
    
    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
    
    % smooth equally in all dimensions
    h = myGaussian3(floor(nbBins/10), filterVariance);
  
elseif strcmp(args.ColorSpace, 'rgb')
    fprintf('Keeping RGB ...\n');
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
    
    % smooth equally in all dimensions
    h = myGaussian3(floor(nbBins/10), filterVariance);

elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    fprintf('Converting to HSV...\n');
    imgSrc = rgb2hsv(imgSrc);
    imgDst = rgb2hsv(imgDst);
    
    mins = [0 0 0];
    maxs = [1 1 1];
    type = 3;
    
    % smooth more in S
    h = myGaussian3(floor(nbBins/10), diag([filterVariance filterVariance*2 filterVariance]));
elseif strcmp(args.ColorSpace, 'lalphabeta')
    % convert the image to the l-alpha-beta color space
    fprintf('Converting to L-alpha-beta...\n');
    imgSrc = rgb2lalphabeta(imgSrc);
    imgDst = rgb2lalphabeta(imgDst);

    mins = [-10 -3 -0.5];
    maxs = [0 3 0.5];
    type = 4;
    
    % smooth equally in all dimensions
    h = myGaussian3(floor(nbBins/10), filterVariance);
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.localEval(type).colorSpace = args.ColorSpace;

%% Compute the object and the image histograms
wSrc = str2double(objInfo.image.size.width);
hSrc = str2double(objInfo.image.size.height);

% load the object's polygon, and extract its mask
objPoly = getPoly(objInfo.object.polygon);
objPoly = objPoly .* repmat(([imgWidth imgWidth] ./ [wSrc hSrc]), size(objPoly, 1), 1);
objMask = poly2mask(objPoly(:,1), objPoly(:,2), imgWidth, imgWidth); 

bgMask= imresize(bgMask, [imgWidth imgWidth], 'nearest'); %#ok

indObjSrc = objMask(:);
indBgSrc = ~objMask(:);

indBgDst = bgMask(:);

% Reshape image into vector
imgDst = reshape(imgDst, 256*256, 3);
imgSrc = reshape(imgSrc, 256*256, 3);

%% Compute the joint statistics
fprintf('Computing the joint...');
histObjJoint = myHistoND(imgSrc(indObjSrc,:), nbBins, mins, maxs);
histObjJointNorm = histObjJoint ./ sum(histObjJoint(:));

histBgDstJoint = myHistoND(imgDst(indBgDst,:), nbBins, mins, maxs);
histBgDstJointNorm = histBgDstJoint ./ sum(histBgDstJoint(:));

histBgSrcJoint = myHistoND(imgSrc(indBgSrc,:), nbBins, mins, maxs);
histBgSrcJointNorm = histBgSrcJoint ./ sum(histBgSrcJoint(:));

histBgDstJointWeighted = histBgDstJoint .* histObjJointNorm;
if ~sum(histBgDstJointWeighted(:))
    overlapDst = 0;
    histBgDstJointWeightedNorm = [];
else
    histBgDstJointWeightedNorm = histBgDstJointWeighted ./ sum(histBgDstJointWeighted(:));
    overlapDst = 1;
end

histBgSrcJointWeighted = histBgSrcJoint .* histObjJointNorm;
if ~sum(histBgSrcJointWeighted(:))
    overlapSrc = 0;
    histBgSrcJointWeightedNorm = [];
else
    histBgSrcJointWeightedNorm = histBgSrcJointWeighted ./ sum(histBgSrcJointWeighted(:));
    overlapSrc = 1;
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

histBgSrcJointWeightedSmooth = histBgSrcJoint .* histObjJointSmooth;
if ~sum(histBgSrcJointWeightedSmooth(:))
    overlapSrcSmooth = 0;
    histBgSrcJointWeightedSmoothNorm = [];
else
    histBgSrcJointWeightedSmoothNorm = histBgSrcJointWeightedSmooth ./ sum(histBgSrcJointWeightedSmooth(:));
    overlapSrcSmooth = 1;
end

%% Try all local measures
% Obj and BgDst
imgInfo = setFieldDist(imgInfo, type, 'objBgDst', 'joint', 1, ...
    histObjJointNorm, histBgDstJointNorm, 1, nbBins);

% Obj and BgSrc
imgInfo = setFieldDist(imgInfo, type, 'objBgSrc', 'joint', 1, ...
    histObjJointNorm, histBgSrcJointNorm, 1, nbBins);

% BgSrc and BgDst
imgInfo = setFieldDist(imgInfo, type, 'bgBg', 'joint', 1, ...
    histBgSrcJointNorm, histBgDstJointNorm, 1, nbBins);

% Obj and BgDst(Obj)
imgInfo = setFieldDist(imgInfo, type, 'objBgDstW', 'joint', 1, ...
    histObjJointNorm, histBgDstJointWeightedNorm, overlapDst, nbBins);

% Obj and BgSrc(Obj)
imgInfo = setFieldDist(imgInfo, type, 'objBgSrcW', 'joint', 1, ...
    histObjJointNorm, histBgSrcJointWeightedNorm, overlapSrc, nbBins);

% BgSrc(Obj) and BgDst(Obj)
imgInfo = setFieldDist(imgInfo, type, 'bgBgW', 'joint', 1, ...
    histBgSrcJointWeightedNorm, histBgDstJointWeightedNorm, overlapSrc && overlapDst, nbBins);

% Obj and BgDstSmooth(Obj)
imgInfo = setFieldDist(imgInfo, type, 'objBgDstWS', 'joint', 1, ...
    histObjJointNorm, histBgDstJointWeightedSmoothNorm, overlapDstSmooth, nbBins);

% Obj and BgSrcSmooth(Obj)
imgInfo = setFieldDist(imgInfo, type, 'objBgSrcWS', 'joint', 1, ...
    histObjJointNorm, histBgSrcJointWeightedSmoothNorm, overlapSrcSmooth, nbBins);

% BgSrcSmooth(Obj) and BgDstSmooth(Obj)
imgInfo = setFieldDist(imgInfo, type, 'bgBgWS', 'joint', 1, ...
    histBgSrcJointWeightedSmoothNorm, histBgDstJointWeightedSmoothNorm, overlapSrcSmooth && overlapDstSmooth, nbBins);

%% Compute the marginals 
fprintf('Computing the marginals...');

for c=1:3
    histObj = squeeze(sum(sum(histObjJoint, mod(c,3)+1), mod(c+1,3)+1));
    histObjNorm = histObj ./ sum(histObj(:));
    
    histBgSrc = squeeze(sum(sum(histBgSrcJoint, mod(c,3)+1), mod(c+1,3)+1));
    histBgSrcNorm = histBgSrc ./ sum(histBgSrc(:));

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
        
    histBgSrcWeighted = histBgSrc .* histObjNorm;
    if ~sum(histBgSrcWeighted(:))
        overlapSrc = 0;
        histBgSrcWeightedNorm = [];
    else
        histBgSrcWeightedNorm = histBgSrcWeighted ./ sum(histBgSrcWeighted(:));
        overlapSrc = 1;
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

    histBgSrcWeightedSmooth = histBgSrc .* squeeze(sum(sum(histObjJointSmooth, mod(c,3)+1), mod(c+1,3)+1));
    if ~sum(histBgSrcWeightedSmooth(:))
        overlapSrcSmooth = 0;
        histBgSrcWeightedSmoothNorm = [];
    else
        histBgSrcWeightedSmoothNorm = histBgSrcWeightedSmooth ./ sum(histBgSrcWeightedSmooth(:));
        overlapSrcSmooth = 1;
    end
    
    % Obj and BgDst
    imgInfo = setFieldDist(imgInfo, type, 'objBgDst', 'marginal', c, ...
        histObjNorm, histBgDstNorm, 1, nbBins);

    % Obj and BgSrc
    imgInfo = setFieldDist(imgInfo, type, 'objBgSrc', 'marginal', c, ...
        histObjNorm, histBgSrcNorm, 1, nbBins);

    % BgSrc and BgDst
    imgInfo = setFieldDist(imgInfo, type, 'bgBg', 'marginal', c, ...
        histBgSrcNorm, histBgDstNorm, 1, nbBins);

    % Obj and BgDst(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'objBgDstW', 'marginal', c, ...
        histObjNorm, histBgDstWeightedNorm, overlapDst, nbBins);

    % Obj and BgSrc(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'objBgSrcW', 'marginal', c, ...
        histObjNorm, histBgSrcWeightedNorm, overlapSrc, nbBins);

    % BgSrc(Obj) and BgDst(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'bgBgW', 'marginal', c, ...
        histBgSrcWeightedNorm, histBgDstWeightedNorm, overlapSrc && overlapDst, nbBins);
    
    % Obj and BgDstSmooth(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'objBgDstWS', 'marginal', c, ...
        histObjNorm, histBgDstWeightedSmoothNorm, overlapDstSmooth, nbBins);

    % Obj and BgSrcSmooth(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'objBgSrcWS', 'marginal', c, ...
        histObjNorm, histBgSrcWeightedSmoothNorm, overlapSrcSmooth, nbBins);

    % BgSrcSmooth(Obj) and BgDstSmooth(Obj)
    imgInfo = setFieldDist(imgInfo, type, 'bgBgWS', 'marginal', c, ...
        histBgSrcWeightedSmoothNorm, histBgDstWeightedSmoothNorm, overlapSrcSmooth && overlapDstSmooth, nbBins);
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


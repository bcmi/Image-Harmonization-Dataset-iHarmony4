%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingBgNN
%   Evaluate the matching of a test image based on the chi-square distance
%   between the pasted object's original image background and the target
%   image background's histograms
% 
% Input parameters:
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnEvaluateMatchingBgNN(annotation, dbPath, outputBasePath, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
% load tmp.mat;
% outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/matchingResults/';

%% Initialize
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox/;
addpath ../database;
addpath ../histogram;
addpath ../xml;

% nbBinsMarginal = 256;
% nbBinsJoint = 64;
nbBinsMarginal = 100;
nbBinsJoint = 20;
fracScore = 0.95;


% read arguments
defaultArgs = struct('ColorSpace', [], 'ImgIndVec', [], 'ObjIndVec', [], ...
    'MarginalVec', [], 'JointVec', [], 'MarginalVecBg', [], 'JointVecBg', [], ...
    'Database', []);
args = parseargs(defaultArgs, varargin{:});

% read the target image and the xml information
imgPath = fullfile(dbPath, annotation.image.folder, 'lossless', annotation.image.filename);
imgTgt = imread(imgPath);

[pathstr, fileName, ext, versn] = fileparts(annotation.image.filename);
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));
if exist(xmlPath, 'file')
    imgInfo = readStructFromXML(xmlPath);
else
    imgInfo.image = annotation.image;
end

% Make sure there's at least one object
if ~isfield(annotation, 'object')
    fprintf('Image contains no labelled objects. Skipping...\n');
    return;
end
% There should be only 1 object. We will always take the first either way.
objInd = 1;

% make sure the image isn't too big. Resize to 256x256
imgTgt = imresize(imgTgt, [256,256]);


if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...');
    imgTgt = rgb2lab(imgTgt);
    
    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
  
elseif strcmp(args.ColorSpace, 'rgb')
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;

elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    fprintf('Converting to HSV...');
    imgTgt = rgb2hsv(imgTgt);
    
    mins = [0 0 0];
    maxs = [1 1 1];
    type = 3;

else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.colorStatistics(type).colorSpace = args.ColorSpace;

wSrc = sscanf(annotation.object(objInd).imgSrc.size.width, '%f');
hSrc = sscanf(annotation.object(objInd).imgSrc.size.height, '%f');

% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(annotation.object(objInd).polygon);
objPoly = [xPoly yPoly]';
objPoly = objPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(objPoly, 2));

objMask = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256); 
indObj = find(objMask);
indBg = find(~objMask);

% Reshape image into vector
imgTgtVec = reshape(imgTgt, 256*256, 3);

%% Compute the marginals 1st-order statistics
fprintf('Computing the marginals...');
for t=1:3
    histObj = single(myHistoND(imgTgtVec(indObj,t), nbBinsMarginal, mins(t), maxs(t)));
    histObj = histObj ./ sum(histObj(:));
    
    histBg = single(myHistoND(imgTgtVec(indBg,t), nbBinsMarginal, mins(t), maxs(t)));
    histBg = histBg ./ sum(histBg(:));
    
    % compute the chi-square distance to all the other object's histograms
    distChi = zeros(1, length(args.MarginalVec{type}));
    distDot = zeros(1, length(args.MarginalVec{type}));
    for i=1:length(args.MarginalVec{type})
        histDbObj = args.MarginalVec{type}(i, :, t);
        distChi(i) = chisq(histObj(:), histDbObj(:));
        distDot(i) = histObj(:)' * histDbObj(:);
    end
    
    [sortedDistChi, indChi] = sort(distChi);
    [sortedDistDot, indDot] = sort(distDot, 'descend');
    
    % look at all the objects which are at > 90% of the best score
    indChiSorted = find(sortedDistChi <= 1-((1-sortedDistChi(2))*fracScore));
    indDotSorted = find(sortedDistDot >= sortedDistDot(2)*fracScore);
    
    % remove the first one (it's the same image!)
    indChiSorted = indChiSorted(2:end);
    indDotSorted = indDotSorted(2:end);
    
    % compute the chi-square distance with the *backgrounds* of the
    % corresponding images
    distChiBg = zeros(1, length(indChiSorted));
    for i=1:length(indChiSorted)
        histDbBg = args.MarginalVecBg{type}(indChi(indChiSorted(i)), :, t);
        distChiBg(i) = chisq(histBg(:), histDbBg(:));
    end
    % idem for dot-product
    distDotBg = zeros(1, length(indDotSorted));
    for i=1:length(indDotSorted)
        histDbBg = args.MarginalVecBg{type}(indDot(indDotSorted(i)), :, t);
        distDotBg(i) = histBg(:)' * histDbBg(:);
    end
    
    [minDistChi, indMinChi] = min(distChiBg);
    indMinChi = indChi(indChiSorted(indMinChi));
    [maxDistDot, indMaxDot] = max(distDotBg);
    indMaxDot = indDot(indDotSorted(indMaxDot));
   
    % update the xml information
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).distChi = minDistChi;
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).folder = args.Database(args.ImgIndVec(indMinChi)).annotation.folder;
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).filename = args.Database(args.ImgIndVec(indMinChi)).annotation.filename;
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).objInd = args.ObjIndVec(indMinChi);

    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).distDot = maxDistDot;
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).folder = args.Database(args.ImgIndVec(indMaxDot)).annotation.folder;
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).filename = args.Database(args.ImgIndVec(indMaxDot)).annotation.filename;
    imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.marginal(t).objInd = args.ObjIndVec(indMaxDot);
end
fprintf('done!\n');

%% Compute the joint statistics
fprintf('Computing the joint...');
histObj = myHistoND(imgTgtVec(indObj,:), nbBinsJoint, mins, maxs);
histObj = histObj ./ sum(histObj(:));

histBg = myHistoND(imgTgtVec(indBg,:), nbBinsJoint, mins, maxs);
histBg = histBg ./ sum(histBg(:));

% compute the chi-square distance to all the other object's histograms
distChi = zeros(1, size(args.JointVec{type}, 1));
distDot = zeros(1, size(args.JointVec{type}, 1));
for i=1:size(args.JointVec{type}, 1)
    histDbObj = squeeze(args.JointVec{type}(i, :, :, :));
    distChi(i) = chisq(histObj(:), histDbObj(:));
    distDot(i) = histObj(:)' * histDbObj(:);
end

[sortedDistChi, indChi] = sort(distChi);
[sortedDistDot, indDot] = sort(distDot, 'descend');

% look at all the objects which are at > 90% of the best score
indChiSorted = find(sortedDistChi <= 1-((1-sortedDistChi(2))*fracScore));
indDotSorted = find(sortedDistDot >= sortedDistDot(2)*fracScore);

% remove the first one (it's the same image!)
indChiSorted = indChiSorted(2:end);
indDotSorted = indDotSorted(2:end);

% compute the chi-square distance with the *backgrounds* of the
% corresponding images
distChiBg = zeros(1, length(indChiSorted));
for i=1:length(indChiSorted)
    histDbBg = squeeze(args.JointVecBg{type}(indChi(indChiSorted(i)), :, :, :));
    distChiBg(i) = chisq(histBg(:), histDbBg(:));
end
% idem for dot-product
distDotBg = zeros(1, length(indDotSorted));
for i=1:length(indDotSorted)
    histDbBg = squeeze(args.JointVecBg{type}(indDot(indDotSorted(i)), :, :, :));
    distDotBg(i) = histBg(:)' * histDbBg(:);
end

[minDistChi, indMinChi] = min(distChiBg);
indMinChi = indChi(indChiSorted(indMinChi));
[maxDistDot, indMaxDot] = max(distDotBg);
indMaxDot = indDot(indDotSorted(indMaxDot));

% update the xml information
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.distChi = minDistChi;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.folder = args.Database(args.ImgIndVec(indMinChi)).annotation.folder;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.filename = args.Database(args.ImgIndVec(indMinChi)).annotation.filename;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.objInd = args.ObjIndVec(indMinChi);

imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.distDot = maxDistDot;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.folder = args.Database(args.ImgIndVec(indMaxDot)).annotation.folder;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.filename = args.Database(args.ImgIndVec(indMaxDot)).annotation.filename;
imgInfo.colorStatistics(type).matchingEvaluationHistoBgNN.joint.objInd = args.ObjIndVec(indMaxDot);

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);

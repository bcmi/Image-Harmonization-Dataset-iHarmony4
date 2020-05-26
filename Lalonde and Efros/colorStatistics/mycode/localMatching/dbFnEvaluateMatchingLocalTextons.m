%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingLocalTextons
%   Evaluate the matching of a test image based on different local measures (which don't require the
%   use of global statistics), based only on similar regions (using texton histogram distance)
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnEvaluateMatchingLocalTextons(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;
nbBins = 100;

% read arguments
defaultArgs = struct('ColorSpace', [], 'DbPath', [], 'ImagesPath', [], ...
    'SubsampledImagesPath', [], 'ObjectDbPath', []);
args = parseargs(defaultArgs, varargin{:});

% read the composite image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);

[h,w,c] = size(img);

% read the masks
maskPath = fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename);
load(maskPath); % objMask, bgMask

% read the texton distance map
textonDistPath = fullfile(args.DbPath, annotation.file.folder, annotation.local.textonMatching.filename);
textonDist = imresize(imread(textonDistPath), [h w], 'bilinear');
textonDist = double(textonDist) ./ 255; % normalize <-- there might be a problem here! Better to save in .mat file?
textonDist(bgMask == 0) = 1;

textonWeight = ones(size(textonDist)) - textonDist;

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);

if exist(xmlPath, 'file')
    imgInfo = loadXML(xmlPath);
else
    imgInfo.image = annotation.image;
    imgInfo.file = annotation.file;
end

%% Convert color spaces
if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...\n');
    imgColor = rgb2lab(img);
    
    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
    
elseif strcmp(args.ColorSpace, 'rgb')
    fprintf('Keeping RGB ...\n');
    imgColor = img;
    
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
    
elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    fprintf('Converting to HSV...\n');
    imgColor = rgb2hsv(img);
    
    mins = [0 0 0];
    maxs = [1 1 1];
    type = 3;
    
elseif strcmp(args.ColorSpace, 'lalphabeta')
    % convert the image to the l-alpha-beta color space
    fprintf('Converting to L-alpha-beta...\n');
    imgColor = rgb2lalphabeta(img);

    mins = [-10 -3 -0.5];
    maxs = [0 3 0.5];
    type = 4;
    
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.localEval(type).colorSpace = args.ColorSpace;

%% Compute the object and background's histograms
imgVec = double(reshape(imgColor, [h*w 3]));

% must have at least 5% of the background with weight higher than 0.7 for a match
overlapTextonW = nnz(textonWeight(bgMask(:)) > 0.7) / nnz(bgMask) > 0.05;

fprintf('Computing the joint...');
histObjJoint = myHistoND(imgVec(objMask(:),:), nbBins, mins, maxs);
histBgDstJoint = myHistoNDWeighted(imgVec(bgMask(:),:), textonWeight(bgMask(:)), nbBins, mins, maxs);

%% Try all local measures
% Obj and BgDst
imgInfo = setFieldDist(imgInfo, type, 'objBgDstTextonW', 'joint', 1, histObjJoint, histBgDstJoint, overlapTextonW, nbBins);

%% Compute the marginals 
fprintf('Computing the marginals...');

for c=1:3
    histObj = squeeze(sum(sum(histObjJoint, mod(c,3)+1), mod(c+1,3)+1));
    histBgDst = squeeze(sum(sum(histBgDstJoint, mod(c,3)+1), mod(c+1,3)+1));

    % Obj and BgDst
    imgInfo = setFieldDist(imgInfo, type, 'objBgDstTextonW', 'marginal', c, histObj, histBgDst, overlapTextonW, nbBins);
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
    % we don't know if it's realistic or not
    imgInfo.localEval(type).(fieldName).(subFieldName)(c).distChi = -1;
    imgInfo.localEval(type).(fieldName).(subFieldName)(c).distDot = -1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnGenerateSemanticImages(outputBasePath, annotation, varargin) 
%   Generate test images for color co-occurences experiments
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnGenerateSyntheticImages(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global processDatabaseImgNumber;

%%
% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'ImagesPath', [], 'MaskStackPath', [], 'Keywords', [], ...
    'Database', [], 'DatabasePath', [], 'MaskWidth', 0, 'ImageSize', 0, 'NewIndices', [], ...
    'IndicesToKeep', [], 'TopKeywords', []);
args = parseargs(defaultArgs, varargin{:});

% retrieve the current keyword
keyword = args.Keywords{processDatabaseImgNumber};

% filter out PASCAL background images because they are too centered around one particular object
if strfind(annotation.image.folder, 'PASCAL')
    fprintf('PASCAL image detected. Skipping...\n');
    return;
end

% load up the corresponding mask stack
maskStackPath = fullfile(args.MaskStackPath, sprintf('%s_stack.mat', keyword));
load(maskStackPath);

% load the object's mask
maskPath = fullfile(args.DatabasePath, annotation.image.folder, annotation.mask.transMask.filename);
load(maskPath);

% resize the mask to the correct size
mask = imresize(mask, [args.MaskWidth args.MaskWidth], 'nearest'); %#ok

% h = fspecial('gaussian', 10, 2);
% mask = imfilter(double(mask), h);

%% Find the nearest neighbor (second because the first one will be itself)
% compute the ssd to each mask in the stack
indKeyword = find(strcmp(args.TopKeywords, keyword));
indToKeep = args.IndicesToKeep{indKeyword};

maskStack = maskStack(:,:,indToKeep); %#ok
maskIndices = maskIndices(indToKeep); %#ok

sqDist = sum(sum((repmat(mask, [1 1 size(maskStack, 3)]) - maskStack).^2, 1), 2);
sqDist = squeeze(sqDist);

[sortedDist, sortedInd] = sort(sqDist);

% sanity check: make sure the object has minimal to itself (might not necessarily be the first
% one, in the case where 2 objects have exactly the same mask)
if sortedDist(sortedInd == find(maskIndices == args.NewIndices(processDatabaseImgNumber))) ~= 0
    error('Object does not have 0 distance with itself');
end 

% remove the original object
indOrig = sortedInd == find(maskIndices == args.NewIndices(processDatabaseImgNumber));
sortedInd(indOrig) = [];

% retrieve the corresponding object's index 
minInd = find(args.NewIndices == maskIndices(sortedInd(1)));

% retrieve the nearest object's information
nearestObjInfo = args.Database(minInd).document;

%% Compute original aspect ratio and keep it to avoid weird distorsions that might affect the result
origRatio = str2double(annotation.image.origSize.width) / str2double(annotation.image.origSize.height);

if origRatio > 1
    imageW = args.ImageSize .* origRatio;
    imageH = args.ImageSize;
else
    imageW = args.ImageSize;
    imageH = args.ImageSize ./ origRatio;
end

imageW = round(imageW);
imageH = round(imageH);

%% Load and resize the nearest object's image
origObjImg = imread(fullfile(args.ImagesPath, nearestObjInfo.image.folder, nearestObjInfo.image.filename));
[hO,wO,d] = size(origObjImg); %#ok
objImg = imresize(origObjImg, [imageH imageW], 'nearest');

%% Load and resize the background image
origBgImg = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));
[hB,wB,d] = size(origBgImg); %#ok
bgImg = imresize(origBgImg, [imageH imageW], 'nearest');

%% Generate the composite

% Load and resize the polygon to match the new size
bgPoly = getPoly(annotation.object.polygon);
bgPoly = bgPoly .* repmat([imageW / wB, imageH / hB], size(bgPoly, 1), 1);
bgPolyCenter = min(bgPoly) + (max(bgPoly) - min(bgPoly))./2;

% Load and resize the matching object's polygon to match the new size
objPoly = getPoly(nearestObjInfo.object.polygon);
objPoly = objPoly .* repmat([imageW / wO, imageH / hO], size(objPoly, 1), 1);
objPolyCenter = min(objPoly) + (max(objPoly) - min(objPoly))./2;

% re-center the polygon at the background's polygon center
transPoly = fix(bgPolyCenter - objPolyCenter);
dstPoly = objPoly + repmat((transPoly), size(objPoly, 1), 1);

% Shift the object's image
objImg = circshift(objImg, [transPoly(2) transPoly(1) 0]);

% Apply simple feathering
objMask = poly2mask(dstPoly(:,1), dstPoly(:,2), imageH, imageW);

seRadius = 3;
seErode = strel('disk', seRadius);
objErode = double(imerode(objMask, seErode));

distObj = bwdist(objErode);
distBg = bwdist(ones(imageH, imageW) - objMask);

alphaMask = ones(imageH, imageW) - distObj ./ (distObj + distBg);

% Composite the image
newImg = uint8(double(objImg) .* repmat(alphaMask, [1 1 3]) + double(bgImg) .* (1-repmat(alphaMask, [1 1 3])));

% Compute normalized score (amount of overlap, normalized by the background's object size)
normalizedScore = nnz(maskStack(:,:,sortedInd(1)) & mask) ./ nnz(mask); %#ok

%% Display (don't forget to disable)

% fprintf('Keyword: %s, Object name: %s, Normalized score: %f\n', keyword, nearestObjInfo.object.name, normalizedScore);
% figure(1);
% subplot(1,3,1), imshow(newImg), subplot(1,3,2), imshow(objImg), subplot(1,3,3), imshow(bgImg);
% pause;
% 
% return;

%% Save the rendered image
outputImgDir = fullfile(outputBasePath, 'Images');
outputAnnDir = fullfile(outputBasePath, 'Annotation');
[m,m,m] = mkdir(outputImgDir); %#ok
[m,m,m] = mkdir(outputAnnDir); %#ok

% save the image
% [path,name] = fileparts(annotation.image.filename);
name = 'image';
name = sprintf('%s_%06d', name, processDatabaseImgNumber);
imgName = sprintf('%s.jpg', name);
outputImgPath = fullfile(outputImgDir, imgName);
xmlPath = fullfile(outputAnnDir, sprintf('%s.xml', name));

imwrite(newImg, outputImgPath, 'Quality', 100);

% save the masks
maskSubDir = 'masks';
maskPath = fullfile(outputAnnDir, maskSubDir);
[m,m,m] = mkdir(maskPath); %#ok

masksName = sprintf('%s.mat', name);
bgMask = logical(ones(size(objMask)) - objMask); %#ok
objMask = logical(objErode); %#ok
save(fullfile(maskPath, masksName), 'objMask', 'bgMask');

% Generate the xml information
imgInfo.image.filename = imgName;
imgInfo.image.folder = '';
imgInfo.file.filename = strrep(imgName, '.jpg', '.xml');
imgInfo.file.folder = '';
imgInfo.image.size.width = imageW;
imgInfo.image.size.height = imageH;
imgInfo.image.origSize.width = wB;
imgInfo.image.origSize.height = hB;

imgInfo.image.generated = 1;
imgInfo.object.objectId = nearestObjInfo.object.objectId;
imgInfo.object.name = nearestObjInfo.object.name;
imgInfo.object.masks.filename = fullfile(maskSubDir, masksName);
imgInfo.object.keyword = keyword;
imgInfo.score = num2str(normalizedScore);
imgInfo.objImgSrc = nearestObjInfo.image;
imgInfo.bgImgSrc = annotation.image;

% save the xml
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

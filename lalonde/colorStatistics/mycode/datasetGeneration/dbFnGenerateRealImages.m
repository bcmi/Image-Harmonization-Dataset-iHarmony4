%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnGenerateRealImages(outputBasePath, annotation, varargin) 
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
function dbFnGenerateRealImages(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global processDatabaseImgNumber;

%%
% check if the user specified the option to recompute
defaultArgs = struct('ImagesPath', [], 'Keywords', [], ...
    'Database', [], 'DatabasePath', [], 'ImageSize', 0, 'NewIndices', []);
args = parseargs(defaultArgs, varargin{:});

% retrieve the current keyword
keyword = args.Keywords{processDatabaseImgNumber};

%% Load and resize the background image
bgImg = imread(fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename));
[hB,wB,d] = size(bgImg);
newImg= imresize(bgImg, [args.ImageSize args.ImageSize], 'nearest');

%% Compute the masks
% resize the mask to the correct size
objPoly = getPoly(annotation.object.polygon);
objPoly = objPoly .* repmat([args.ImageSize / wB, args.ImageSize/ hB], size(objPoly, 1), 1);
objMask = poly2mask(objPoly(:,1), objPoly(:,2), args.ImageSize, args.ImageSize);

seRadius = 3;
se = strel('disk', seRadius);
objErode = double(imerode(objMask, se));
objDilate = double(imdilate(objMask, se));

%% Save the rendered image
outputImgDir = fullfile(outputBasePath, 'Images');
outputAnnDir = fullfile(outputBasePath, 'Annotation');
[m,m,m] = mkdir(outputImgDir);
[m,m,m] = mkdir(outputAnnDir);

% save the image
name = 'image';
name = sprintf('%s_%06d', name, processDatabaseImgNumber + 100000); % real images have an offset to prevent colliding with synthetic images
imgName = sprintf('%s.jpg', name);
outputImgPath = fullfile(outputImgDir, imgName);
xmlPath = fullfile(outputAnnDir, sprintf('%s.xml', name));

imwrite(newImg, outputImgPath, 'Quality', 100);

% save the masks
maskSubDir = 'masks';
maskPath = fullfile(outputAnnDir, maskSubDir);
[m,m,m] = mkdir(maskPath);

masksName = sprintf('%s.mat', name);
objMask = logical(objErode); %#ok
bgMask = logical(ones(size(objDilate)) - objDilate);%#ok
save(fullfile(maskPath, masksName), 'objMask', 'bgMask');

% figure(1), subplot(1,3,1), imshow(newImg), subplot(1,3,2), imshow(objMask), subplot(1,3,3), imshow(bgMask);
% pause;

% Generate the xml information
imgInfo.image.filename = imgName;
imgInfo.image.folder = '';
imgInfo.file.filename = strrep(imgName, '.jpg', '.xml');
imgInfo.file.folder = '';
imgInfo.image.size.width = args.ImageSize;
imgInfo.image.size.height = args.ImageSize;
imgInfo.image.origSize.width = wB;
imgInfo.image.origSize.height = hB;

imgInfo.image.generated = 0;
imgInfo.object.objectId = annotation.object.objectId;
imgInfo.object.name = annotation.object.name;
imgInfo.object.masks.filename = fullfile(maskSubDir, masksName);
imgInfo.object.keyword = keyword;
imgInfo.imageSrc = annotation.image;

% save the xml
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnGenerateSemanticTestImages(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
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
function ret = dbFnGenerateSemanticTestImages(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% load tmp.mat;
ret = 1;
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/LabelMeToolbox;
addpath ../msStitching;
addpath ../database;
addpath ../xml;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'Database', [], 'ImgPath', '', ...
    'ImgFilename', [], 'DistMatrix', [], 'MaskVec', [], ...
    'ImgIndVec', [], 'ObjIndVec', [], 'CurInd', 0);
args = parseargs(defaultArgs, varargin{:});

% read the image
img = imread(imgPath);

% initialize the imgInfo structure
imgInfo.image.filename = annotation.filename;
imgInfo.image.folder = annotation.folder;

% Resize the image
[h,w,d] = size(img);
img = imresize(img, [256 256], 'bilinear');
imgInfo.image.size.width = 256;
imgInfo.image.size.height = 256;
imgInfo.image.origSize.width = w;
imgInfo.image.origSize.height = h;

[d,indMat] = sort(args.DistMatrix(args.CurInd, :), 2);
r = ceil(rand*5)+1; %randomly between 2 and 6
indImg = args.ImgIndVec(indMat(r));
indObj = args.ObjIndVec(indMat(r));

randAnnotation = args.Database(indImg);

h = montage(permute(args.MaskVec(indMat(1:9), :, :), [2 3 4 1]));
drawnow;

% Select an object at random and get its polygon
[xPoly, yPoly] = getLMpolygon(randAnnotation.annotation.object(indObj).polygon);
srcPoly = [xPoly yPoly]';

% Load the source image 
srcFile = fullfile(args.ImgPath, randAnnotation.annotation.folder, randAnnotation.annotation.filename);
srcImg = imread(srcFile);

[hSrc,wSrc,c] = size(srcImg);

% Resize the destination polygon
dstPoly = srcPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(srcPoly, 2));


%% Copy the pixels
fakeImg = pasteObjectOnImage(img, dstPoly, srcImg, srcPoly, srcImg);

%% Save the rendered image
outputImgDir = fullfile(outputBasePath, 'images');
[s,m,m] = mkdir(outputImgDir);

imgInfo.image.generated = 1;
imgInfo.object = randAnnotation.annotation.object(indObj);
imgInfo.object.imgSrc.path = srcFile;
imgInfo.object.imgSrc.size.width = size(srcImg, 2);
imgInfo.object.imgSrc.size.height = size(srcImg, 1);
imgInfo.object.indSrc = indObj;

% save the image
outputImgPath = fullfile(outputImgDir, sprintf('%s_generated.jpg', args.ImgFilename));
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', args.ImgFilename));
imwrite(fakeImg, outputImgPath);
% imwrite(fakeImg, strrep(outputImgPath, 'ppm', '.jpg', '.ppm'));
imgMontage = get(h, 'CData');
imwrite(imgMontage, strrep(outputImgPath, '.jpg', '_montage.jpg'));

imgInfo.image.filename = sprintf('%s_generated.jpg', args.ImgFilename);
imgInfo.image.folder = 'images/';
imgInfo.image.originalFolder = annotation.folder;
imgInfo.image.originalFilename = annotation.filename;

% save the xml
fprintf('Saving xml file: %s\n', xmlPath);
[pathstr, name, ext, versn] = fileparts(xmlPath);
xmlPath = fullfile(pathstr, sprintf('%s_generated.xml', name));
writeStructToXML(imgInfo, xmlPath);

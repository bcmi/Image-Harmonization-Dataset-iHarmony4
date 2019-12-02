%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnGenerateTestImages(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
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
function ret = dbFnGenerateTestImages(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% load tmp.mat;

addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/LabelMeToolbox;
addpath ../msStitching;
addpath ../database;
addpath ../xml;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'Database', [], 'ImgPath', '', ...
    'IndSegmentedImg', [], 'ImgFilename', []);
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

% object to paste must occupy between 5% and 60% of the image
minArea = 256*256*0.05;
maxArea = 256*256*0.6;

ret = 0;

%% Make sure the image contains at least one object that is of the right size
if isfield(annotation, 'object')
    isOk = 0;
    indRand = randperm(length(annotation.object));
    for i=indRand
        [xPoly, yPoly] = getLMpolygon(annotation.object(i).polygon);
        objPoly = [xPoly yPoly]';
        objPoly = objPoly .* repmat(([256 256]' ./ [w h]'), 1, size(objPoly, 2));

        areaObj = nnz(poly2mask(objPoly(1,:), objPoly(2,:), 256, 256));
        if areaObj > minArea && areaObj < maxArea
            % select the object index for generating the test image
            isOk = 1;
            indObjOriginal = i;
            break;
        end
    end
    if ~isOk
        fprintf('Selected image contains no object of sufficient size! Skipping...\n');
        return;
    end
else
    fprintf('Selected image contains no object! Skipping...\n');
    return;
end

%% Randomly select an image (which contains an object) in the database
% Get only the images that contain objects
indSegmentedImages = args.IndSegmentedImg;

areaObj = 0;
while areaObj < minArea || areaObj > maxArea
    % Select an image at random
    randInd = ceil(rand * length(indSegmentedImages));
    indImg = indSegmentedImages(randInd);
    randAnnotation = args.Database(indImg);

    % Select an object at random and get its polygon
    randInd = ceil(rand * length(randAnnotation.annotation.object));
    [xPoly, yPoly] = getLMpolygon(randAnnotation.annotation.object(randInd).polygon);
    objPoly = [xPoly yPoly]';
    
    % Load and resize the image
    srcFile = fullfile(args.ImgPath, randAnnotation.annotation.folder, randAnnotation.annotation.filename);
    srcImg = imread(srcFile);
    
    [h,w,d] = size(srcImg);
    srcImg = imresize(srcImg, [256 256], 'bilinear');
    objPoly = objPoly .* repmat(([256 256]' ./ [w h]'), 1, size(objPoly, 2));
    
    areaObj = nnz(poly2mask(objPoly(1,:), objPoly(2,:), 256, 256));
end

%% Copy the pixels
fakeImg = pasteObjectOnImage(img, objPoly, srcImg, objPoly, srcImg);

%% Save the rendered image
outputImgDir = fullfile(outputBasePath, 'images');
[s,m,m] = mkdir(outputImgDir);

imgInfo.image.generated = 1;
imgInfo.object = randAnnotation.annotation.object(randInd);
imgInfo.object.imgSrc = srcFile;
imgInfo.object.indSrc = randInd;

% save the image
outputImgPath = fullfile(outputImgDir, sprintf('%s_generated.jpg', args.ImgFilename));
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', args.ImgFilename));
imwrite(fakeImg, outputImgPath, 'Mode', 'lossless', 'Quality', 100);

imgInfo.image.filename = sprintf('%s_generated.jpg', args.ImgFilename);
imgInfo.image.folder = 'images';
imgInfo.image.originalFolder = annotation.folder;
imgInfo.image.originalFilename = annotation.filename;

% save the xml
fprintf('Saving xml file: %s\n', xmlPath);
[pathstr, name, ext, versn] = fileparts(xmlPath);
xmlPath = fullfile(pathstr, sprintf('%s_generated.xml', name));
writeStructToXML(imgInfo, xmlPath);

%% Save the original image
% save the object that comes from the same image
imgInfo.object = annotation.object(indObjOriginal);

% save the image
outputImgPath = fullfile(outputImgDir, sprintf('%s.jpg', args.ImgFilename));
imwrite(img, outputImgPath, 'Mode', 'lossless', 'Quality', 100);
   
% save the xml
imgInfo.image.generated = 0; % mention that this is the original image
imgInfo.image.filename = sprintf('%s.jpg', args.ImgFilename);
imgInfo.image.folder = 'images';
imgInfo.image.originalFolder = annotation.folder;
imgInfo.image.originalFilename = annotation.filename;
xmlPath = fullfile(pathstr, sprintf('%s.xml', name));
writeStructToXML(imgInfo, xmlPath);

ret = 1;
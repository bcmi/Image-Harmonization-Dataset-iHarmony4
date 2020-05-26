%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingLocalTextonsColor
%   Evaluate the matching of a test image based on different local measures (which don't require the
%   use of global statistics), based only on similar regions (using texton histogram distance)
% 
% Input parameters:
%
% Output parameters:
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r=dbFnPrecomputeSignatures(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
r=0;

% read arguments
defaultArgs = struct('ColorSpace', [], 'DbPath', [], 'ImagesPath', [], 'NbClusters', 0);
args = parseargs(defaultArgs, varargin{:});

% read the composite image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% load the masks
load(fullfile(args.DbPath, annotation.file.folder, annotation.object.masks.filename));

% load the object's polygon, and extract its mask
% objPoly = getPoly(annotation.object.polygon);
% objMask = logical(poly2mask(objPoly(:,1), objPoly(:,2), h, w)); 

% bgMask = logical(ones(h,w) - double(imdilate(objMask, strel('disk', 5))));

if nnz(objMask) < args.NbClusters * 1.5
    fprintf('Not enough points to cluster (object is too small)! Skipping... \n');
    return;
end

%% Convert color spaces
if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...\n');
    imgColor = rgb2lab(img);
    
    type = 1;
    
elseif strcmp(args.ColorSpace, 'rgb')
    fprintf('Keeping RGB ...\n');
    imgColor = img;
    
    type = 2;
    
elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    fprintf('Converting to HSV...\n');
    imgColor = rgb2hsv(img);
    
    type = 3;
    
elseif strcmp(args.ColorSpace, 'lalphabeta')
    % convert the image to the l-alpha-beta color space
    fprintf('Converting to L-alpha-beta...\n');
    imgColor = rgb2lalphabeta(img);

    type = 4;
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgVec = double(reshape(imgColor, [h*w 3]));

imgVecObj = imgVec(objMask(:), :);
imgVecBg = imgVec(bgMask(:), :);

maxNbPoints = 100000;
indObj = randperm(size(imgVecObj, 1));
indObj = indObj(1:min(size(imgVecObj,1), maxNbPoints));
indBg = randperm(size(imgVecBg, 1));
indBg = indBg(1:min(size(imgVecBg,1), maxNbPoints));

%% Compute the object and background signatures
[centersObj, weightsObj, indsObj] = signaturesKmeans(imgVecObj(indObj, :), args.NbClusters); %#ok
[centersBg, weightsBg, indsBg] = signaturesKmeans(imgVecBg(indBg, :), args.NbClusters); %#ok

%% Save information and update xml
imgInfo = annotation;
imgInfo.signatures(type).filename = fullfile('signatures', args.ColorSpace, strrep(annotation.file.filename, '.xml', '.mat'));
imgInfo.signatures(type).colorSpace = args.ColorSpace;
imgInfo.signatures(type).nbClusters = args.NbClusters;
outputDir = fullfile(outputBasePath, annotation.file.folder, 'signatures', args.ColorSpace);
[m,m,m] = mkdir(outputDir); %#ok

save(fullfile(outputDir, strrep(annotation.file.filename, '.xml', '.mat')), 'centersObj', 'weightsObj', 'centersBg', 'weightsBg', 'indsObj', 'indsBg');

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnTestBatchTextonMatching(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnComputeTextonMatching(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'SubsampledImagesPath', [], 'ImageDbPath', [], ...
    'SyntheticDbPath', [], 'ObjectDbPath', [], 'Threshold', 0, 'HtmlInfo', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% read the source image and its texton map
objImgPath = fullfile(args.SubsampledImagesPath, annotation.objImgSrc.folder, annotation.objImgSrc.filename);
objImg = imread(objImgPath);
objImgInfo = loadXML(fullfile(args.ImageDbPath, annotation.objImgSrc.folder, strrep(annotation.objImgSrc.filename, '.jpg', '.xml')));
objTextonMapPath = fullfile(args.ImageDbPath, objImgInfo.file.folder, objImgInfo.univTextons.textonMap);
load(objTextonMapPath); objTextonMap = textonMap;

% read the background image and its texton map
bgImgPath = fullfile(args.SubsampledImagesPath, annotation.bgImgSrc.folder, annotation.bgImgSrc.filename);
bgImg = imread(bgImgPath);
bgImgInfo = loadXML(fullfile(args.ImageDbPath, annotation.bgImgSrc.folder, strrep(annotation.bgImgSrc.filename, '.jpg', '.xml')));
bgTextonMapPath = fullfile(args.ImageDbPath, bgImgInfo.file.folder, bgImgInfo.univTextons.textonMap);
load(bgTextonMapPath); bgTextonMap = textonMap;

% load the masks
load(fullfile(args.SyntheticDbPath, annotation.file.folder, annotation.object.masks.filename)); %bgMask, objMask
% resize the background mask to the source image size
bgMask = imresize(bgMask, [size(bgImg, 1) size(bgImg,2)], 'nearest'); %#ok

% re-build the object mask
objInfo = loadXML(fullfile(args.ObjectDbPath, objImgInfo.file.folder, ...
    sprintf('%s_%04d.xml', strrep(objImgInfo.file.filename, '.xml', ''), str2double(annotation.object.objectId))));
objPoly = getPoly(objInfo.object.polygon);
objMask = poly2mask(objPoly(:,1), objPoly(:,2), size(objImg,1), size(objImg,2));

% compute the object's texton histogram
objTextonMap = histc(objTextonMap(objMask(:)), 1:1000);

% find similar patches in the bg image
fprintf('Finding matches using sliding windows...'); tic;
[distMap,t] = matchTextonsSlidingWindow(bgImg, bgTextonMap, objTextonMap, args.Threshold); 
fprintf('done in %fs\n', toc);

% mask out the bg mask (make sure we don't find the object within itself)
% distMap = distMap .* bgMask; %#ok
distMap(bgMask == 0) = 1;

% save the distMap to file
imgInfo = annotation;
imgInfo.local.textonMatching.filename = fullfile('local', 'textonMatching', strrep(annotation.file.filename, '.xml', '.jpg'));
outputDir = fullfile(outputBasePath, annotation.file.folder, 'local', 'textonMatching');
[m,m,m] = mkdir(outputDir); %#ok

imwrite(distMap, fullfile(outputDir, strrep(annotation.file.filename, '.xml', '.jpg')), 'Quality', 100);

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
writeXML(xmlPath, imgInfo);

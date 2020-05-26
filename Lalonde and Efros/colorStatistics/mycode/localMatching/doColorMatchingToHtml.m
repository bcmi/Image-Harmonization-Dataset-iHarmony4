%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doColorMatchingToHtml
%   
% Input parameters:
%
% Output parameters:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doColorMatchingToHtml
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global count;
addpath ../;
setPath;

% define the paths
subsampledImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/';
imageDbPath = fullfile(basePath, 'imageDb');
objectDbPath = fullfile(basePath, 'objectDb');
dbBasePath = fullfile(basePath, 'dataset', 'filteredDb');
dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');

outputBasePath = dbPath;
outputHtmlPath = 'colorStatistics/colorMatching';
dbFn = @dbFnColorMatchingToHtml;

% Setup html stuff
htmlInfo = [];
[htmlInfo.experimentNb, htmlInfo.outputDirExperiment, htmlInfo.outputDirFig, ...
    htmlInfo.outputDirJpg, htmlInfo.outputHtmlFileName] = setupBatchTest(outputHtmlPath, '');

% call the database
count = 0;
parallelized = 0;
randomized = 1;
processResultsDatabaseFast(dbPath, 'image_1', outputBasePath, dbFn, parallelized, randomized, ...
    'ImagesPath', imagesPath, 'SubsampledImagesPath', subsampledImagesPath, ...
    'ImageDbPath', imageDbPath, 'ObjectDbPath', objectDbPath, ...
    'SyntheticDbPath', dbPath, 'HtmlInfo', htmlInfo);


function r = dbFnColorMatchingToHtml(outputBasePath, annotation, varargin) 
global count;
r=0;

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'SubsampledImagesPath', [], 'ImageDbPath', [], ...
    'ObjectDbPath', [], 'SyntheticDbPath', [], 'HtmlInfo', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% read the background image and its texton map
bgImgPath = fullfile(args.SubsampledImagesPath, annotation.bgImgSrc.folder, annotation.bgImgSrc.filename);
bgImg = imresize(imread(bgImgPath), [h w], 'bilinear');

% load the masks
load(fullfile(args.SyntheticDbPath, annotation.file.folder, annotation.object.masks.filename)); %bgMask, objMask

% load the color weight 
colorDist = double(imread(fullfile(args.SyntheticDbPath, annotation.file.folder, annotation.local.colorMatching.filename))) ./ 255;

% build the threshold version
colorMask3 = colorDist < 0.3;
colorThreshold3 = uint8(double(bgImg) .* repmat(colorMask3, [1 1 3]));

colorMask4 = colorDist < 0.4;
colorThreshold4 = uint8(double(bgImg) .* repmat(colorMask4, [1 1 3]));

% draw the object outline
objOutline = bwperim(objMask);
iB = repmat(zeros(h, w), [1 1 2]);
iB(:,:,3) = objOutline;
img(repmat(objOutline, [1 1 2])) = 0;
img(find(iB)) = 255;

% prepare the output file names
[path, name] = fileparts(annotation.file.filename);
compFn = sprintf('%s_comp.jpg', name);
maskFn = sprintf('%s_mask.jpg', name);
thresh3Fn = sprintf('%s_thresh3.jpg', name);
thresh4Fn = sprintf('%s_thresh4.jpg', name);

% save all images to file
imwrite(img, fullfile(args.HtmlInfo.outputDirJpg, compFn));
imwrite(imresize(colorDist, [size(img,1) size(img,2)], 'bilinear'), fullfile(args.HtmlInfo.outputDirJpg, maskFn));
imwrite(imresize(colorThreshold3, [size(img,1) size(img,2)], 'bilinear'), fullfile(args.HtmlInfo.outputDirJpg, thresh3Fn));
imwrite(imresize(colorThreshold4, [size(img,1) size(img,2)], 'bilinear'), fullfile(args.HtmlInfo.outputDirJpg, thresh4Fn));

% build html structure
% title row
cellArray(1,:) = {'Composite image', 'Matching distance', sprintf('Thresholded at d < %.2f', 0.3), sprintf('Thresholded at d < %.2f', 0.4)};

% add a row to the cell array
cellArray(2,:) = {...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, compFn), fullfile('jpg', compFn), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, maskFn), fullfile('jpg', maskFn), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, thresh3Fn), fullfile('jpg', thresh3Fn), 'Width', 200), ...
    img2html(fullfile(args.HtmlInfo.outputDirJpg, thresh4Fn), fullfile('jpg', thresh4Fn), 'Width', 200), ...
    };

% append to html
cell2html(cellArray, args.HtmlInfo.outputHtmlFileName, ...
    'StandAlone', false, 'Caption', annotation.image.filename, ...
    'StyleClass', 'results', 'StyleSheet', '../../../style.css');

count = count + 1;
if count > 200
    fprintf('Processed %d images. Done!\n', count);
    r = 1;
end



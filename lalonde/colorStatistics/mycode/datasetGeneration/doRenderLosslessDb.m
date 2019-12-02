%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function doRenderLosslessDb
%   Re-renders the database and saves in a lossless format (to avoid
%   compression artefacts). 
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doRenderLosslessDb 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
addpath '../database/';
addpath ../../3rd_party/parseArgs;

% define the input and output paths
imgPath = '/nfs/hn21/projects/labelme/Images/';
dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/';
outputBasePath = '/nfs/hn01/jlalonde/results/colorStatistics/testData/images/';
subDirs = {'.'};

dbFn = @dbFnRenderLosslessDb;

%% call the database function
processResultsDatabaseParallelFast(dbPath, outputBasePath, subDirs, dbFn, ...
    'ImgPath', imgPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingBgNN(annotation, dbPath, outputBasePath, varargin)
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
function dbFnRenderLosslessDb(annotation, dbPath, outputBasePath, varargin)

addpath ../msStitching;
addpath ../../3rd_party/LabelMeToolbox;

% read arguments
defaultArgs = struct('ImgPath', []);
args = parseargs(defaultArgs, varargin{:});

% read the original (target) image
tgtImg = imread(fullfile(args.ImgPath, annotation.image.originalFolder, annotation.image.originalFilename));
tgtImg = imresize(tgtImg, [256 256], 'bilinear');
    
% only re-render the image if it was generated
if sscanf(annotation.image.generated, '%d')
    % read the source image (that contains the pasted object)
    srcImg = imread(annotation.object.imgSrc.path);

    [xPoly, yPoly] = getLMpolygon(annotation.object.polygon);
    srcPoly = [xPoly yPoly]';

    % Resize the target polygon
    [hSrc,wSrc,c] = size(srcImg);
    tgtPoly = srcPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(srcPoly, 2));

    fakeImg = pasteObjectOnImage(tgtImg, tgtPoly, srcImg, srcPoly, srcImg);
else
    fakeImg = tgtImg;
end

% Save the generated image in an lossless compression format
outputFile = fullfile(outputBasePath, 'lossless', annotation.image.filename);
imwrite(fakeImg, outputFile, 'Mode', 'lossless');
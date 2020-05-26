%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnComputeColorMatching(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnComputeColorMatching(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

nbBins = 100;
mins = [0 -100 -100];
maxs = [100 100 100];

% check if the user specified the option to relabel
defaultArgs = struct('ImagesPath', [], 'SubsampledImagesPath', [], 'ImageDbPath', [], ...
    'SyntheticDbPath', [], 'ObjectDbPath', [], 'Threshold', 0, 'HtmlInfo', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% load the masks
load(fullfile(args.SyntheticDbPath, annotation.file.folder, annotation.object.masks.filename)); %bgMask, objMask

% convert the object and background images to lab
fprintf('Converting to Lab...');
imgLab = rgb2lab(img);
fprintf('done.\n');

% try marginals
imgLabVec = reshape(imgLab, [h*w c]);
objHisto = zeros(nbBins, 3);
for c=1:3
    objHisto(:,c) = myHistoND(imgLabVec(objMask(:), c), nbBins, mins(c), maxs(c));
end

% find similar patches in the bg image
fprintf('Finding matches using sliding windows...'); tic;
distMap = matchMarginalColorSlidingWindow(imgLab, objHisto, nbBins, mins, maxs); 
fprintf('done in %fs\n', toc);

% mask out the bg mask (make sure we don't find the object within itself)
distMap(bgMask == 0) = 1;

% save the distMap to file
imgInfo = annotation;
imgInfo.local.colorMatching.filename = fullfile('local', 'colorMatching', strrep(annotation.file.filename, '.xml', '.jpg'));
imgInfo.local.colorMatching.colorSpace = 'lab';
imgInfo.local.colorMatching.nbBins = nbBins;
outputDir = fullfile(outputBasePath, annotation.file.folder, 'local', 'colorMatching');
[m,m,m] = mkdir(outputDir); %#ok

imwrite(distMap, fullfile(outputDir, strrep(annotation.file.filename, '.xml', '.jpg')), 'Quality', 100);

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
writeXML(xmlPath, imgInfo);

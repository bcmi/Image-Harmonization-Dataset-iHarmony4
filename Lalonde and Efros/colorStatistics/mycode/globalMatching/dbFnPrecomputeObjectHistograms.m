%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnPrecomputeObjectHistograms(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnPrecomputeObjectHistograms(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

%% Setup
% check if the user specified the option to relabel
defaultArgs = struct('ColorSpace', [], 'ObjectDbPath', [], 'ImagesPath', [], 'NbBins', 0, 'ActiveInd', []);
args = parseargs(defaultArgs, varargin{:});

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% retrieve the object and background masks
polygon = getPoly(annotation.object.polygon);
objMask = poly2mask(polygon(:,1), polygon(:,2), h, w);

% dilate the object slightly to avoid picking up the boundaries
bgMask = logical(ones(h,w) - imdilate(objMask, strel('disk', 5)));

%% Color space conversion
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

imgVec = reshape(imgColor, [h*w c]);

%% Compute marginal and joint histograms 
fprintf('Computing histograms...');
margObjHisto = zeros(args.NbBins, 3);
margBgHisto = zeros(args.NbBins, 3);
for c=1:3
    margObjHisto(:,c) = myHistoND(imgVec(objMask(:), c), args.NbBins, mins(c), maxs(c));
    margBgHisto(:,c) = myHistoND(imgVec(bgMask(:), c), args.NbBins, mins(c), maxs(c));
end

jointObjHisto = myHistoND(imgVec(objMask(:), :), args.NbBins, mins, maxs);
jointBgHisto = myHistoND(imgVec(bgMask(:), :), args.NbBins, mins, maxs);

% only keep the useful part
jointObjHisto = jointObjHisto(args.ActiveInd);
jointBgHisto = jointBgHisto(args.ActiveInd);

fprintf('done.\n');

%% Save information to file
% save the distMap to file
xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
imgInfo = loadXML(xmlPath);
imgInfo.histograms(type).filename = fullfile('histograms', args.ColorSpace, strrep(annotation.file.filename, '.xml', '.mat'));
imgInfo.histograms(type).colorSpace = args.ColorSpace;
imgInfo.histograms(type).nbBins = args.NbBins;
outputDir = fullfile(outputBasePath, annotation.file.folder, 'histograms', args.ColorSpace);
[m,m,m] = mkdir(outputDir); %#ok

save(fullfile(outputDir, strrep(annotation.file.filename, '.xml', '.mat')), 'jointObjHisto', 'jointBgHisto', 'margObjHisto', 'margBgHisto');

xmlPath = fullfile(outputBasePath, annotation.file.folder, annotation.file.filename);
writeXML(xmlPath, imgInfo);

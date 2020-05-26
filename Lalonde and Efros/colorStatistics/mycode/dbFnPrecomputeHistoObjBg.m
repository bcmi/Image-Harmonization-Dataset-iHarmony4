%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Computes the co-occurences of colors in an image using the texton idea. 
%   Saves the results (2-D prob. density in a .mat file)
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%     - 'ColorSpace':
%       - 'rgb': Use the original RGB colorspace (not supported now)
%       - 'lab': Use the CIE Lab colorspace
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnPrecomputeHistoObjBg(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% load tmp.mat;

addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/vgg_matlab/vgg_general;
addpath ../../3rd_party/LabelMeToolbox;
addpath ../database;
addpath ../histogram;
addpath ../xml;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'ColorSpace', 'lab', ...
    'MinArea', 0, 'MaxArea', 0, 'NbBins', 0);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
[imgOrig, imgInfo, recompute, xmlPath] = readImageInfo(imgPath, outputBasePath, annotation, 'colorStatistics', args.Recompute);

if ~recompute
    fprintf('Already computed. Skipping...\n');
    return;   
elseif isempty(imgOrig)
    imgOrig = imread(imgPath);
end

% make sure the image isn't too big. Resize to 256x256
[hSrc,wSrc,c] = size(imgOrig);
img = imresize(imgOrig, [256,256], 'bilinear');

if strcmp(args.ColorSpace, 'lab')
    % convert the image to the L*a*b* color space (if asked by the user)
    fprintf('Converting to L*a*b*...');
    img = rgb2lab(img);
    
    % L = [0 100]
    % a = [-100 100]
    % b = [-100 100]
    mins = [0 -100 -100];
    maxs = [100 100 100];
    type = 1;
elseif strcmp(args.ColorSpace, 'rgb')
    fprintf('Keeping RGB...');
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
elseif strcmp(args.ColorSpace, 'hsv')
    fprintf('Converting to HSV...');
    img = rgb2hsv(img);
    mins = [0 0 0];
    maxs = [1 1 1];
    type = 3;
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.colorStatisticsHistograms(type).colorSpace = args.ColorSpace;
[pathstr, name, ext, versn] = fileparts(annotation.filename);

% find if the histograms were already computed
if isfield(imgInfo.colorStatisticsHistograms(type), 'histograms')
    binInd = length(imgInfo.colorStatisticsHistograms(type).histograms)+1;
    for i=1:length(imgInfo.colorStatisticsHistograms(type).histograms)
        if imgInfo.colorStatisticsHistograms(type).histograms(i).nbBins == args.NbBins
            if args.Recompute
                binInd = i;
            end
        end
    end
else
    binInd = 1;
end

% update the xml
imgInfo.colorStatisticsHistograms(type).histograms(binInd).nbBins = args.NbBins;
imgInfo.colorStatisticsHistograms(type).histograms(binInd).minArea = args.MinArea;
imgInfo.colorStatisticsHistograms(type).histograms(binInd).maxArea = args.MaxArea;

%% Get all the masks of the objects that are of the right size
polys = getPolysMinMaxArea(annotation, imgOrig, imagesBasePath, args.MinArea, args.MaxArea);
nbObjects = length(polys);

if ~nbObjects
    imgInfo.colorStatisticsHistograms(type).nbObjects = 0;
    fprintf('No object found: saving xml file: %s\n', xmlPath);
%     writeStructToXML(imgInfo, xmlPath);
    return;
end

masks = zeros(nbObjects, 256, 256);
for o=1:nbObjects
    objPoly = polys{o} .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(polys{o}, 2));
    masks(o,:,:) = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256);
end

% montage(permute(masks, [2 3 4 1]).*255)

%% Compute the histograms for the image, object and background

imgVec = reshape(img, 256*256, 3);
nbBins = args.NbBins;

% Histogram the quantized patches
histObj = zeros(nbObjects, nbBins, nbBins, nbBins);
sparseHistObj = sparse(nbObjects, nbBins^3);
histBg = zeros(nbObjects, nbBins, nbBins, nbBins);
sparseHistBg = sparse(nbObjects, nbBins^3);

sparseHistImg = sparse(reshape(myHistoND(imgVec, nbBins, mins, maxs), nbBins^2, nbBins));

%%% HERE!
for o=1:nbObjects
    histObj(o,:,:,:) = myHistoND(imgVec(find(masks(o,:,:)),:), nbBins, mins, maxs); %#ok
    sparseHistObj = sparse(reshape(histObj, nbBins^2, nbBins));
    histBg(o,:,:,:) = myHistoND(imgVec(find(~masks(o,:,:)),:), nbBins, mins, maxs); %#ok
    sparseHistBg = sparse(reshape(histBg, nbBins^2, nbBins));
end

%% Save the histograms to file
outputDirName = fullfile('colorStatisticsHistograms', sprintf('%d_bins', nbBins), args.ColorSpace);
outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));

% make sure the directory exists
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'sparseHistImg', 'sparseHistObj', 'sparseHistBg');

% update the xml information
imgInfo.colorStatisticsHistograms(type).histograms(binInd).nbObjects = nbObjects;
imgInfo.colorStatisticsHistograms(type).histograms(binInd).file = outputFileName;

%% Save the xml
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);


%%
function polys = getPolysMinMaxArea(annotation, img, imagesBasePath, minAreaRatio, maxAreaRatio)

polys = [];
if isfield(annotation, 'object')
%     imgOrig = imread(fullfile(imagesBasePath, annotation.folder, annotation.filename));
    imgArea = size(img,1)*size(img,2);
    
    polyCount = 1;
    for objInd=1:length(annotation.object);
        [xPoly, yPoly] = getLMpolygon(annotation.object(objInd).polygon);

        areaObj = polyarea(xPoly, yPoly) ./ imgArea;

        if areaObj > minAreaRatio && areaObj < maxAreaRatio
            polys{polyCount} = [xPoly yPoly]';
            polyCount = polyCount + 1;
        end
    end
end

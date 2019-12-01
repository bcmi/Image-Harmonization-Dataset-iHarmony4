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
function dbFnCoOccurencesTextonsObjBg(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
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
defaultArgs = struct('Recompute', 1, 'ColorSpace', 'lab', 'ClusterCenters', [], 'N', 0, ...
    'MinArea', 0, 'MaxArea', 0);
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
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).colorSpace = args.ColorSpace;
[pathstr, name, ext, versn] = fileparts(annotation.filename);

% initialize the current image's patches to zero
nbClusters = size(args.ClusterCenters, 2);

% update the xml
imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).nbClusters= nbClusters;
imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).minArea = args.MinArea;
imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).maxArea = args.MaxArea;

%% Get all the masks of the objects that are of the right size
polys = getPolysMinMaxArea(annotation, imgOrig, imagesBasePath, args.MinArea, args.MaxArea);
nbObjects = length(polys);

if ~nbObjects
    imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).nbObjects = 0;
    fprintf('No object found: saving xml file: %s\n', xmlPath);
    writeStructToXML(imgInfo, xmlPath);
    return;
end

masks = zeros(nbObjects, 256, 256);
for i=1:nbObjects
    objPoly = polys{i} .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(polys{i}, 2));
    masks(i,:,:) = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256);
end
% montage(permute(masks, [2 3 4 1]).*255)
%% extract all the 3x3 color patches from the image
% initialize the current image's patches to zero
N = args.N;
nbPatchesRow = 256-N+1;
imagePatches = zeros(nbPatchesRow^2, (N^2)*3);

lims = ceil(N/2):ceil(N/2)+nbPatchesRow-1;
halfSize = floor(N/2);
fprintf('Gathering patches...'); tic;

patchObj = zeros(nbObjects, nbPatchesRow^2, 1);
patchBg = zeros(nbObjects, nbPatchesRow^2, 1);

c=1;
for i=lims
    for j=lims
        patch = reshape(img(i-halfSize:i+halfSize, j-halfSize:j+halfSize, :), N^2, 3);
        % sort the patch colors along the L dimension (first dimension)
        
%         [s, ind] = sort(patch(:,1));
        ind = 1:size(patch,1);
        patch = reshape(patch(ind, :), 1, N^2*3);
        
        imagePatches(c,:) = patch;
        
        % check if patch is in the object or not
        inside = sum(reshape(masks(:,i-halfSize:i+halfSize, j-halfSize:j+halfSize), nbObjects, N^2), 2);
        patchObj(inside == N^2,c) = 1;
        patchBg(inside == 0,c) = 1;
        
        c = c+1;
    end
end
t = toc;
fprintf('done in %.2f sec.\n', t);

%% Quantize the image
fprintf('Quantizing the image...'); tic;
[quantizedPatches, d] = vgg_nearest_neighbour(imagePatches', args.ClusterCenters);
t=toc; fprintf('done in %.2f sec.\n', t);

%% Now the image is quantized. Compute the histograms for the image, object and background

% Histogram the quantized patches
textonHistObj = sparse(nbObjects, nbClusters);
textonHistBg = sparse(nbObjects, nbClusters);

textonHistImg = sparse(myHistoND(quantizedPatches, nbClusters, 1, nbClusters));
for o=1:nbObjects
    textonHistObj(o,:) = sparse(myHistoND(quantizedPatches(logical(patchObj(o,:)), :), nbClusters, 1, nbClusters));
    textonHistBg(o,:) = sparse(myHistoND(quantizedPatches(logical(patchBg(o,:)), :), nbClusters, 1, nbClusters));
end

%% Save the histograms to file
outputDirName = fullfile('colorStatisticsTextons5x5ObjBgUnsorted', args.ColorSpace);
outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));

% make sure the directory exists
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'textonHistImg', 'textonHistObj', 'textonHistBg');

% update the xml information
imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).nbObjects = nbObjects;
imgInfo.colorStatisticsTextons5x5ObjBgUnsorted(type).file = outputFileName;

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

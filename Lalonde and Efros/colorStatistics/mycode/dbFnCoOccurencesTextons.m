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
function dbFnCoOccurencesTextons(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
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
addpath ../database;
addpath ../histogram;
addpath ../xml;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'ColorSpace', 'lab', 'ClusterCenters', [], 'N', 0);
args = parseargs(defaultArgs, varargin{:});
args.Recompute = 1;

% read the image and the xml information
[img, imgInfo, recompute, xmlPath] = readImageInfo(imgPath, outputBasePath, annotation, 'colorStatistics', args.Recompute);

if ~recompute
    fprintf('Already computed. Skipping...\n');
    return;   
elseif isempty(img)
    img = imread(imgPath);
end

% make sure the image isn't too big. Resize to 256x256
img = imresize(img, [256,256], 'bilinear');

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
    mins = [0 0 0];
    maxs = [255 255 255];
    type = 2;
    error('Color Space %s unsupported!', args.ColorSpace);
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.colorStatisticsTextons5x5Unsorted(type).colorSpace = args.ColorSpace;
[pathstr, name, ext, versn] = fileparts(annotation.filename);

% initialize the current image's patches to zero
nbClusters = size(args.ClusterCenters, 2);

% update the xml
imgInfo.colorStatisticsTextons5x5Unsorted(type).nbClusters= nbClusters;

%% extract all the 3x3 color patches from the image
% initialize the current image's patches to zero
N = args.N;
nbPatchesRow = 256-N+1;
imagePatches = zeros(nbPatchesRow^2, (N^2)*3);

lims = ceil(N/2):ceil(N/2)+nbPatchesRow-1;
halfSize = floor(N/2);
fprintf('Gathering patches...'); tic;
c=1;
for i=lims
    for j=lims
        patch = reshape(img(i-halfSize:i+halfSize, j-halfSize:j+halfSize, :), N^2, 3);
        % sort the patch colors along the L dimension (first dimension)
        
%         [s, ind] = sort(patch(:,1));
        ind = 1:size(patch,1);
        patch = reshape(patch(ind, :), 1, N^2*3);
        
        imagePatches(c,:) = patch;
        c = c+1;
    end
end
t = toc;
fprintf('done in %.2f sec.\n', t);

%% Quantize the image
fprintf('Quantizing the image...'); tic;
[quantizedPatches, d] = vgg_nearest_neighbour(imagePatches', args.ClusterCenters);
t=toc; fprintf('done in %.2f sec.\n', t);

%% Now the image is quantized. Compute the 1st-order histogram

% Histogram the quantized patches
textonHist1stOrder = sparse(myHistoND(quantizedPatches, nbClusters, 1, nbClusters));

%% Save the 1st-order histogram to file
outputDirName = fullfile('colorStatisticsTextons5x5Unsorted', args.ColorSpace, '1stOrder');
outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
% make sure the directory exists
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'textonHist1stOrder');

% update the xml information
imgInfo.colorStatisticsTextons5x5Unsorted(type).firstOrder.file = outputFileName;

%% Compute the 2nd-order histogram (co-occurences)

% Compute co-occurences
% find the non-zero entries in the histogram
colorInd = find(textonHist1stOrder);

% we can use sparse, since it will be a 2-dimensional histogram
textonHist2ndOrder = sparse(nbClusters, nbClusters);

% set the corresponding entries to the 1st order histogram
textonHist2ndOrder(colorInd,:) = repmat(textonHist1stOrder(:)', length(colorInd), 1);

%% Save the 2nd-order histogram to file
outputDirName = fullfile('colorStatisticsTextons5x5Unsorted', args.ColorSpace, '2ndOrder');
outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
% make sure the directory exists
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'textonHist2ndOrder');

% update the xml information
imgInfo.colorStatisticsTextons5x5Unsorted(type).secondOrder.file = outputFileName;

%% Save the xml
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);





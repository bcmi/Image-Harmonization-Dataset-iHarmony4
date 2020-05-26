%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Computes the co-occurences of colors in an image. Saves the results
%   (2-D prob. density in a .mat file)
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%     - 'ColorSpace':
%       - 'rgb': Use the original RGB colorspace
%       - 'lab': Use the CIE Lab colorspace
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnCoOccurences(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% load tmp.mat;

addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../database;
addpath ../histogram;
addpath ../xml;

nbBins1stOrder = 64;
nbBins2ndOrder = 16;

% check if the user specified the option to recompute
defaultArgs = struct('Recompute', 1, 'ColorSpace', 'rgb');
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
else
    error('Color Space %s unsupported!', args.ColorSpace);
end

imgInfo.colorStatistics(type).colorSpace = args.ColorSpace;
[pathstr, name, ext, versn] = fileparts(annotation.filename);

%% Compute the 1st and 2nd order statistics

fprintf('Computing the 1st and 2nd order statistics...');
[hist1stOrder, hist2ndOrder] = computeStatistics(img, nbBins1stOrder, nbBins2ndOrder, mins, maxs);
fprintf('done!\n');

% sparse them (they are already normalized)
hist1stOrder = sparse(reshape(hist1stOrder, nbBins1stOrder^2, nbBins1stOrder));
hist2ndOrder = sparse(reshape(hist2ndOrder, nbBins2ndOrder^5, nbBins2ndOrder));


%% Save the 1st-order histogram to file
outputDirName = fullfile('colorStatistics', args.ColorSpace, '1stOrder');
outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
% make sure the directory exists
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'hist1stOrder');

% update the xml information
imgInfo.colorStatistics(type).firstOrder.file = outputFileName;
imgInfo.colorStatistics(type).firstOrder.nbBins = nbBins1stOrder;

%% Save the 2nd-order histogram to file
outputDirName = fullfile('colorStatistics', args.ColorSpace, '2ndOrder');
outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
% make sure the directory exists
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'hist2ndOrder');

% update the xml information
imgInfo.colorStatistics(type).secondOrder.file = outputFileName;
imgInfo.colorStatistics(type).secondOrder.nbBins = nbBins2ndOrder;

%% Save the xml
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);

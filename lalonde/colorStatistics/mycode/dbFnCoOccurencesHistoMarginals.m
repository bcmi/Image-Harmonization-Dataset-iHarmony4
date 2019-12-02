%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnCoOccurencesHistoMarginals(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
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
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dbFnCoOccurencesHistoMarginals(imgPath, imagesBasePath, outputBasePath, annotation, varargin) 
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

nbBinsMarginal1stOrder = 256;
nbBinsMarginal2ndOrder = 128;
nbBinsPairwise1stOrder = 64;
nbBinsPairwise2ndOrder = 32;

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

elseif strcmp(args.ColorSpace, 'hsv')
    % convert the image to the HSV color space
    fprintf('Converting to HSV...');
    img = rgb2hsv(img);
    
    mins = [0 0 0];
    maxs = [1 1 1];
    type = 3;

else
    error('Color Space %s unsupported!', args.ColorSpace);
end

% Reshape image into vector
img = reshape(img, size(img,1)*size(img,2), 3);

imgInfo.colorStatistics(type).colorSpace = args.ColorSpace;
[pathstr, name, ext, versn] = fileparts(annotation.filename);

%% Compute the marginals 1st-order statistics
fprintf('Computing the 1st order marginals...');
hist1stOrderMarginal = zeros(3, nbBinsMarginal1stOrder);
for c=1:3
    histTmp = myHistoND(img(:,c), nbBinsMarginal1stOrder, mins(c), maxs(c));
    histTmp = histTmp ./ sum(histTmp(:));
    hist1stOrderMarginal(c,:) = histTmp;
end

%% Save the 1st-order marginal histogram to file
outputDirName = fullfile('colorStatistics', args.ColorSpace, '1stOrder', 'marginal');
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));

outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'hist1stOrderMarginal');

% update the xml information
imgInfo.colorStatistics(type).firstOrder.marginal.file = outputFileName;
imgInfo.colorStatistics(type).firstOrder.marginal.nbBins = nbBinsMarginal1stOrder;
clear('hist1stOrderMarginal');
fprintf('done!\n');

%% Compute the marginals 2nd-order statistics
fprintf('Computing the 2nd order marginals...');
hist2ndOrderMarginal = zeros(3, nbBinsMarginal2ndOrder, nbBinsMarginal2ndOrder);
for c=1:3
    histTmp = myHistoND(img(:,c), nbBinsMarginal2ndOrder, mins(c), maxs(c));
    histTmp = histTmp ./ sum(histTmp(:));

    % find the non-zero entries in the histogram
    colorInd = find(histTmp);

    % set the corresponding entries to the 1st order histogram
    hist2ndOrderMarginal(c, colorInd, :) = repmat(histTmp', length(colorInd), 1);
end
% Sparse it
hist2ndOrderMarginal = sparse(reshape(hist2ndOrderMarginal, 3, nbBinsMarginal2ndOrder^2));

%% Save the 2nd-order marginal histogram to file
outputDirName = fullfile('colorStatistics', args.ColorSpace, '2ndOrder', 'marginal');
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));

outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'hist2ndOrderMarginal');

% update the xml information
imgInfo.colorStatistics(type).secondOrder.marginal.file = outputFileName;
imgInfo.colorStatistics(type).secondOrder.marginal.nbBins = nbBinsMarginal2ndOrder;
clear('hist2ndOrderMarginal');
fprintf('done!\n');

%% Compute all pairwise joints, 1st order
perms = {[1 2], [1 3], [2 3]};
fprintf('Computing the 1st order pairwise joint histograms...');
hist1stOrderPairwise = zeros(length(perms), nbBinsPairwise1stOrder, nbBinsPairwise1stOrder);
for i=1:length(perms)
    histTmp = myHistoND(img(:,perms{i}), nbBinsPairwise1stOrder, mins(perms{i}), maxs(perms{i}));
    histTmp = histTmp ./ sum(histTmp(:));
    
    hist1stOrderPairwise(i, :, :) = histTmp;
end
% Sparse it
hist1stOrderPairwise = sparse(reshape(hist1stOrderPairwise, 3, nbBinsPairwise1stOrder^2));

%% Save the 1st-order pairwise histogram to file
outputDirName = fullfile('colorStatistics', args.ColorSpace, '1stOrder', 'pairwise');
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));

outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'hist1stOrderPairwise');

% update the xml information
imgInfo.colorStatistics(type).firstOrder.pairwise.file = outputFileName;
imgInfo.colorStatistics(type).firstOrder.pairwise.nbBins = nbBinsPairwise1stOrder;
clear('hist1stOrderPairwise');
fprintf('done!\n');

%% Compute all pairwise joints, 2nd order
fprintf('Computing the 2nd order pairwise joint histograms...');
hist2ndOrderPairwise = zeros([length(perms) repmat(nbBinsPairwise2ndOrder, 1, 4)]);
for i=1:length(perms)
    histTmp = myHistoND(img(:,perms{i}), nbBinsPairwise2ndOrder, mins(perms{i}), maxs(perms{i}));
    histTmp = histTmp ./ sum(histTmp(:));
    
    % find the non-zero entries in the histogram
    colorInd = find(histTmp);
    
    hist2ndTmp = reshape(hist2ndOrderPairwise(i,:,:,:,:), nbBinsPairwise2ndOrder^2, nbBinsPairwise2ndOrder, nbBinsPairwise2ndOrder);
    hist2ndTmp(colorInd, :, :) = repmat(shiftdim(histTmp, -1), [length(colorInd) 1 1]);
    
    hist2ndOrderPairwise(i,:,:,:,:) = reshape(hist2ndTmp, repmat(nbBinsPairwise2ndOrder, 1, 4));
end
% Sparse it
hist2ndOrderPairwise = sparse(reshape(hist2ndOrderPairwise, 3, nbBinsPairwise2ndOrder^4));

%% Save the 2nd-order pairwise histogram to file
outputDirName = fullfile('colorStatistics', args.ColorSpace, '2ndOrder', 'pairwise');
[d,d,d] = mkdir(fullfile(outputBasePath, annotation.folder, outputDirName));

outputFileName = fullfile(outputDirName, sprintf('%s.mat', name));
save(fullfile(outputBasePath, annotation.folder, outputFileName), 'hist2ndOrderPairwise');

% update the xml information
imgInfo.colorStatistics(type).secondOrder.pairwise.file = outputFileName;
imgInfo.colorStatistics(type).secondOrder.pairwise.nbBins = nbBinsPairwise2ndOrder;
clear('hist2ndOrderPairwise');
fprintf('done!\n');

%% Save the xml
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingHistoMarginals(annotation, dbPath, outputBasePath, varargin)
%   Evaluates whether an image matches its expected color distributions
%   (1st and 2nd order). Based solely on histogram comparison.
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
function dbFnEvaluateMatchingHistoMarginals(annotation, dbPath, outputBasePath, varargin)%%
% load tmp.mat;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox/;
addpath ../database;
addpath ../histogram;
addpath ../xml;

nbBinsMarginal1stOrder = 256;
nbBinsMarginal2ndOrder = 128;
nbBinsPairwise1stOrder = 64;
nbBinsPairwise2ndOrder = 32;

% read arguments
defaultArgs = struct('ColorSpace', [], ...
    'Histo1stOrderMarginal', [], ...
    'Histo2ndOrderMarginal', [], ...
    'Histo1stOrderPairwise', [], ...
    'Histo2ndOrderPairwise', []);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
imgPath = fullfile(dbPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);

[pathstr, fileName, ext, versn] = fileparts(annotation.image.filename);
xmlPath = fullfile(outputBasePath, annotation.image.folder, sprintf('%s.xml', fileName));
imgInfo = readStructFromXML(xmlPath);

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

imgInfo.colorStatistics(type).colorSpace = args.ColorSpace;

%% Compute the object and the image histograms
% Make sure there's at least one object
if ~isfield(annotation, 'object')
    fprintf('Image contains no labelled objects. Skipping...\n');
    return;
end

% There should be only 1 object. We will always take the first either way.
objInd = 1;

wSrc = sscanf(annotation.image.origSize.width, '%f');
hSrc = sscanf(annotation.image.origSize.height, '%f');

% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(annotation.object(objInd).polygon);
objPoly = [xPoly yPoly]';
objPoly = objPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(objPoly, 2));
objMask = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256); 

indMask = find(objMask);
indBg = find(~objMask);

% Reshape image into vector
img = reshape(img, size(img,1)*size(img,2), 3);

%% Compute the marginals 1st-order statistics
fprintf('Computing the 1st order marginals...');
for c=1:3
    hist1stOrderMarginal = myHistoND(img(:,c), nbBinsMarginal1stOrder, mins(c), maxs(c));
    hist1stOrderMarginal = hist1stOrderMarginal ./ sum(hist1stOrderMarginal(:));
    
    % normalize the database histogram
    args.Histo1stOrderMarginal{type}(c,:) = args.Histo1stOrderMarginal{type}(c,:) ./ sum(args.Histo1stOrderMarginal{type}(c,:));
        
    distChi = chisq(hist1stOrderMarginal', args.Histo1stOrderMarginal{type}(c,:));
    distDot = hist1stOrderMarginal(:)' * args.Histo1stOrderMarginal{type}(c,:)';
    
    % update the xml information
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.firstOrder(c).marginal.distChi = distChi;
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.firstOrder(c).marginal.distDot = distDot;
end
clear('hist1stOrderMarginal');
fprintf('done!\n');

%% Compute the marginals 2nd-order statistics
fprintf('Computing the 2nd order marginals...');
for c=1:3
    histObj = myHistoND(img(indMask,c), nbBinsMarginal2ndOrder, mins(c), maxs(c));
    histObj = histObj ./ sum(histObj(:));
    
    histBg = myHistoND(img(indBg,c), nbBinsMarginal2ndOrder, mins(c), maxs(c));
    histBg = histBg ./ sum(histBg(:));    

    % Find all the object's colors
    colorInd = find(histObj);
    
    % Sum all the object's color contributions
    sumDbHist = zeros(size(histBg));
    for i=colorInd(:)'
        sumDbHist = sumDbHist + squeeze(args.Histo2ndOrderMarginal{type}(c,i,:));
    end
    sumDbHist = sumDbHist ./ sum(sumDbHist(:));
    
    % compute distances
    distChi = chisq(histBg, sumDbHist);
    distDot = histBg(:)' * sumDbHist(:);

    % update the xml information
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.secondOrder(c).marginal.distChi = distChi;
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.secondOrder(c).marginal.distDot = distDot;
end
fprintf('done!\n');

%% Compute all pairwise joints, 1st order
perms = {[1 2], [1 3], [2 3]};
fprintf('Computing the 1st order pairwise joint histograms...');
for c=1:length(perms)
    hist1stOrderPairwise = myHistoND(img(:,perms{c}), nbBinsPairwise1stOrder, mins(perms{c}), maxs(perms{c}));
    hist1stOrderPairwise = hist1stOrderPairwise ./ sum(hist1stOrderPairwise(:));
    
    % normalize the database histogram
    args.Histo1stOrderPairwise{type}(c,:,:) = args.Histo1stOrderPairwise{type}(c,:,:) ./ sum(sum(args.Histo1stOrderPairwise{type}(c,:,:)));
    
    distChi = chisq(hist1stOrderPairwise, squeeze(args.Histo1stOrderPairwise{type}(c,:,:)));
    distDot = hist1stOrderPairwise(:)' * args.Histo1stOrderPairwise{type}(c,:)';
    
    % update the xml information
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.firstOrder(c).pairwise.distChi = distChi;
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.firstOrder(c).pairwise.distDot = distDot;
end
clear('hist1stOrderPairwise');
fprintf('done!\n');

%% Compute all pairwise joints, 2nd order
fprintf('Computing the 2nd order pairwise joint histograms...');
hist2ndOrderPairwise = zeros([length(perms) repmat(nbBinsPairwise2ndOrder, 1, 4)]);
for c=1:length(perms)
    histObj = myHistoND(img(indMask,perms{c}), nbBinsPairwise2ndOrder, mins(perms{c}), maxs(perms{c}));
    histObj = histObj ./ sum(histObj(:));
    
    histBg = myHistoND(img(indBg,perms{c}), nbBinsPairwise2ndOrder, mins(perms{c}), maxs(perms{c}));
    histBg = histBg ./ sum(histBg(:));    

    % Find all the object's colors
    colorInd = find(histObj);
    
    % Sum all the object's color contributions
    sumDbHist = zeros(size(histBg));
    for i=colorInd(:)'
        [colorR, colorC] = ind2sub(size(histObj), i);

        sumDbHist = sumDbHist + squeeze(args.Histo2ndOrderPairwise{type}(c,colorR,colorC,:,:));
    end
    sumDbHist = sumDbHist ./ sum(sumDbHist(:));
    
    % compute distances
    distChi = chisq(histBg, sumDbHist);
    distDot = histBg(:)' * sumDbHist(:);
    
    % update the xml information
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.secondOrder(c).pairwise.distChi = distChi;
    imgInfo.colorStatistics(type).matchingEvaluationHistoMarginal.secondOrder(c).pairwise.distDot = distDot;
end
fprintf('done!\n');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);


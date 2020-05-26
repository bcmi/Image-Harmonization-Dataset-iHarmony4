%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingHisto(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
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
function dbFnEvaluateMatchingHisto(annotation, dbPath, outputBasePath, varargin)%% Initialize
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/LabelMeToolbox/;
addpath ../database;
addpath ../histogram;
addpath ../xml;
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read arguments
defaultArgs = struct('Recompute', 1, 'ColorSpace', 'rgb', 'Histo1stOrder', [], 'Histo2ndOrder', []);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
imgPath = fullfile(dbPath, annotation.image.folder, 'lossless', annotation.image.filename);
img = imread(imgPath);

[pathstr, fileName, ext, versn] = fileparts(annotation.image.filename);
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));
if exist(xmlPath, 'file')
    imgInfo = readStructFromXML(xmlPath);
else
    imgInfo.image = annotation.image;
end

nbBins1stOrder = size(args.Histo1stOrder, 1);
nbBins2ndOrder = size(args.Histo2ndOrder, 1);


%% Convert color spaces (if needed)
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

% update the xml information
imgInfo.colorStatistics(type).colorSpace = args.ColorSpace;

%% Compute the object and the image histograms
% Make sure there's at least one object
if ~isfield(annotation, 'object')
    fprintf('Image contains no labelled objects. Skipping...\n');
    return;
end

% There should be only 1 object. We will always take the first either way.
objInd = 1;

% load the object's polygon, and extract its mask
wSrc = sscanf(annotation.object(objInd).imgSrc.size.width, '%f');
hSrc = sscanf(annotation.object(objInd).imgSrc.size.height, '%f');

% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(annotation.object(objInd).polygon);
objPoly = [xPoly yPoly]';
objPoly = objPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(objPoly, 2));
objMask = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256); 


%% First-order statistics
fprintf('1st-order...');
img = reshape(img, 256*256, 3);
% compute the histogram of the entire image
histImage = myHistoND(img, nbBins1stOrder, mins, maxs);
histImage = histImage ./ sum(histImage(:));

% normalize
args.Histo1stOrder = args.Histo1stOrder ./ sum(args.Histo1stOrder(:));

% evaluate matching: compute distance between the image histogram and the database histogram
% Chi-square
dist1stOrderChi = chisq(histImage, args.Histo1stOrder);
dist1stOrderDot = histImage(:)' * args.Histo1stOrder(:);

% update xml
imgInfo.colorStatistics(type).matchingEvaluationHisto.firstOrder.distChi = dist1stOrderChi;
imgInfo.colorStatistics(type).matchingEvaluationHisto.firstOrder.distDot = dist1stOrderDot;

%% Second-order statistics
fprintf('2nd-order...');
% compute the histogram of the object's color
histObj = myHistoND(img(objMask(:),:), nbBins2ndOrder, mins, maxs);
histObj = histObj ./ sum(histObj(:));

% compute the histogram of the background's color
histBg = myHistoND(img(~objMask(:),:), nbBins2ndOrder, mins, maxs);
histBg = histBg ./ sum(histBg(:));

% evaluate matching: for each color in the object, compute the distance of
% the histBg to the corresponding color in the database histogram.
% Accumulate all the distances
colorInd = find(histObj);

sumDbHist = zeros(size(histBg));
for c=colorInd(:)'
    % Retrieve the color subscripts from the linear index
    [i1,i2,i3] = ind2sub(size(histObj), c);
    
    % normalize the database histogram
    tmpHist = squeeze(args.Histo2ndOrder(i1,i2,i3,:,:,:));
    if sum(tmpHist(:)) ~= 0
        tmpHist = tmpHist ./ sum(tmpHist(:));
    end
    
    sumDbHist = sumDbHist + tmpHist;
end 

% Normalize the histograms
sumDbHist = sumDbHist ./ sum(sumDbHist(:));

% Then, compute the chi-square distance between the histograms
dist2ndOrderChi = chisq(histBg, sumDbHist);
dist2ndOrderDot = histBg(:)' * sumDbHist(:);

% update xml
imgInfo.colorStatistics(type).matchingEvaluationHisto.secondOrder.distChi = dist2ndOrderChi;
imgInfo.colorStatistics(type).matchingEvaluationHisto.secondOrder.distDot = dist2ndOrderDot;
fprintf('done!\n');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);


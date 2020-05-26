%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnEvaluateMatchingTextons(imgPath, imagesBasePath, outputBasePath, annotation, varargin)
%   Evaluates whether an image matches its expected color distributions
%   (1st and 2nd order). Based on textons distributions
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
function dbFnEvaluateMatchingTextons(annotation, dbPath, outputBasePath, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% load tmp.mat;

%% Initialize
addpath ../../3rd_party/parseArgs;
addpath ../../3rd_party/color;
addpath ../../3rd_party/vgg_matlab/vgg_general;
addpath ../../3rd_party/LabelMeToolbox;
addpath ../database;
addpath ../histogram;
addpath ../xml;

% read arguments
defaultArgs = struct('Histo1stOrder', [], 'Histo2ndOrder', [], 'ClusterCenters', [], 'N', 0);
args = parseargs(defaultArgs, varargin{:});

% read the image and the xml information
[pathstr, fileName, ext, versn] = fileparts(annotation.image.filename);
xmlPath = fullfile(outputBasePath, sprintf('%s.xml', fileName));

if ~exist(xmlPath, 'file')
    imgInfo.image = annotation.image;
else
    imgInfo = readStructFromXML(xmlPath);
end

imgPath = fullfile(dbPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);


%% Convert color spaces
% convert the image to the L*a*b* color space (if asked by the user)
fprintf('Converting to L*a*b*...');
img = rgb2lab(img);

% L = [0 100]
% a = [-100 100]
% b = [-100 100]
mins = [0 -100 -100];
maxs = [100 100 100];
type = 1;

%% Compute the object and the image histograms
% Make sure there's at least one object
if ~isfield(annotation, 'object')
    fprintf('Image contains no labelled objects. Skipping...\n');
    return;
end

% There should be only 1 object. We will always take the first either way.
objInd = 1;

wSrc = sscanf(annotation.object(objInd).imgSrc.size.width, '%f');
hSrc = sscanf(annotation.object(objInd).imgSrc.size.height, '%f');

% load the object's polygon, and extract its mask
[xPoly, yPoly] = getLMpolygon(annotation.object(objInd).polygon);
objPoly = [xPoly yPoly]';
objPoly = objPoly .* repmat(([256 256]' ./ [wSrc hSrc]'), 1, size(objPoly, 2));
objMask = poly2mask(objPoly(1,:), objPoly(2,:), 256, 256); 

%% Quantize the image
N = args.N;
nbPatchesRow = 256-N+1;
imagePatches = zeros(nbPatchesRow^2, (N^2)*3);

lims = ceil(N/2):ceil(N/2)+nbPatchesRow-1;
halfSize = floor(N/2);
patchObj = zeros(nbPatchesRow^2, 1);
patchBg = zeros(nbPatchesRow^2, 1);

fprintf('Gathering patches...'); tic;
c = 1;
for i=lims
    for j=lims
        patch = reshape(img(i-halfSize:i+halfSize, j-halfSize:j+halfSize, :), N^2, 3);
        % sort the patch colors along the L dimension (first dimension)
        
%         [s, ind] = sort(patch(:,1));
        ind = 1:size(patch,1);
        patch = reshape(patch(ind, :), 1, N^2*3);
        
        imagePatches(c,:) = patch;
                
        % check if patch is in the object or not
        inside = sum(reshape(objMask(i-halfSize:i+halfSize, j-halfSize:j+halfSize), N^2, 1));
        if inside == N^2
            patchObj(c) = 1;
        elseif inside == 0
            patchBg(c) = 1;
        end
        c = c+1;
    end
end
t = toc;
fprintf('done in %.2f sec.\n', t);

% Image quantization
fprintf('Quantizing the image...'); tic;
[quantizedPatches, d] = vgg_nearest_neighbour(imagePatches', args.ClusterCenters);
t=toc; fprintf('done in %.2f sec.\n', t);

%% First-order statistics
fprintf('1st-order...');
nbClusters = size(args.ClusterCenters, 2);

% compute the histogram of the entire image
hist1stOrderImage = myHistoND(quantizedPatches, nbClusters, 1, nbClusters);
hist1stOrderImage = hist1stOrderImage ./ sum(hist1stOrderImage(:));

% evaluate matching: compute distance between the image histogram and the database histogram
% Chi-square
dist1stOrderChi = chisq(hist1stOrderImage, args.Histo1stOrder);
dist1stOrderDot = hist1stOrderImage(:)' * args.Histo1stOrder(:);

% update xml
imgInfo.colorStatistics(type).(sprintf('matchingEvaluationTextons%dx%dUnsorted', N, N)).firstOrder.distChi = dist1stOrderChi;
imgInfo.colorStatistics(type).(sprintf('matchingEvaluationTextons%dx%dUnsorted', N, N)).firstOrder.distDot = dist1stOrderDot;

%% Second-order statistics
fprintf('2nd-order...');
% compute the histogram of the object's textons
histObj = myHistoND(quantizedPatches(find(patchObj)), nbClusters, 1, nbClusters);
histObj = histObj ./ sum(histObj(:));

% compute the histogram of the background's textons
histBg = myHistoND(quantizedPatches(find(patchBg)), nbClusters, 1, nbClusters);
histBg = histBg ./ sum(histBg(:));

% evaluate matching: for each color in the object, compute the distance of
% the histBg to the corresponding color in the database histogram.
% Accumulate all the distances
colorInd = find(histObj);

sumDbHist = zeros(size(histBg));
for c=colorInd(:)'
    tmpHist = args.Histo2ndOrder(c,:);
    tmpHist = tmpHist ./ sum(tmpHist(:));
    sumDbHist(:) = sumDbHist(:) + tmpHist(:);
end 

% Normalize the histograms
sumDbHist = sumDbHist ./ sum(sumDbHist(:));

% Then, compute the chi-square distance between the histograms
dist2ndOrderChi = chisq(histBg, sumDbHist);
dist2ndOrderDot = histBg(:)' * sumDbHist(:);

% update xml
imgInfo.colorStatistics(type).(sprintf('matchingEvaluationTextons%dx%dUnsorted', N, N)).secondOrder.distChi = dist2ndOrderChi;
imgInfo.colorStatistics(type).(sprintf('matchingEvaluationTextons%dx%dUnsorted', N, N)).secondOrder.distDot = dist2ndOrderDot;
fprintf('done!\n');

%% Save the xml to disk
fprintf('Saving xml file: %s\n', xmlPath);
writeStructToXML(imgInfo, xmlPath);


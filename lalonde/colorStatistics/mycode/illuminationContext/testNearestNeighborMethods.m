%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function testNearestNeighborMethods
%  
% 
% Input parameters:
%
% Output parameters:
%   
% Warning:
%   - ONLY for joint histograms
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function testNearestNeighborMethods(imageDb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths and load image
addpath ../;
setPath;

origImagesPath = '/nfs/hn21/projects/labelmeSubsampled/Images';

basePath = '/nfs/hn01/jlalonde/results/colorStatistics';
distancesPath = fullfile(basePath, 'illuminationContext', 'distances');
maskDistancesPath = fullfile(basePath, 'illuminationContext', 'distancesMasks');
dbBasePath = fullfile(basePath, 'dataset', 'combinedDb');
popupBasePath = fullfile(basePath, 'dataset', 'combinedDbPopup');

dbPath = fullfile(dbBasePath, 'Annotation');
imagesPath = fullfile(dbBasePath, 'Images');

outputBasePath = fullfile(basePath, 'illuminationContext', 'evaluationResults', 'nearestNeighbor');

% List of files to process
filesToProcess = {'image_000874', 'image_000072', 'image_000089', 'image_000118', ...
    'image_000150', 'image_000115', 'image_001926', 'image_003961', ...
    'image_002289', 'image_002487', 'image_000963'};

% List of techniques to try
matchingTechniques = {...
    'imageWideHisto', ... image-wide histograms
    'weightedHisto', ... weighted histograms for each geometric class
    'averageHisto', ... average histograms for each geometric class
    };

matchingConstraints = {...
    'noConstraint', ... no additional constraint
    'geometricRatio', ... scenes which have similar ratios of geometric classes
    'geometricLayout', ... scenes which have similar geometric classes layout
    'gist', ... scenes which have similar gist
    'gistGeometricLayout', ... scenes which have similar gist *and* geometric layout
    };
    
% List of color spaces
colorSpaces = {'lab'};
colorSpacesInd = {1};

% List of geometric classes
geometricClasses = {{'sky', 'ground', 'vertical'}, ...
    {'sky', 'ground'}};

% Number of nearest neighbor
K = 55;

%% Load weights
load(fullfile(distancesPath, 'weights.mat'));

%% Load the image database
if nargin == 0
    fprintf('Loading the image database...');
    load(fullfile(basePath, 'imageDb', 'imageDb.mat'));
    fprintf('done.\n');
end

%% Gigantic loop over all these options
for f=1:length(filesToProcess)
    fileName = filesToProcess{f};

    % Load image-related information
    xmlPath = fullfile(dbPath, sprintf('%s.xml', fileName));
    imgPath = fullfile(imagesPath, sprintf('%s.jpg', fileName));

    imgInfo = loadXML(xmlPath);
    img = imread(imgPath);

    xmlPopupPath = fullfile(popupBasePath, imgInfo.file.folder, imgInfo.file.filename);
    imgPopupInfo = loadXML(xmlPopupPath);

    
    for c=1:length(colorSpaces)
        colorSpace = colorSpaces{c};
        colorSpaceInd = colorSpacesInd{c};
        
        for g=1:length(geometricClasses)
            geometricClass = geometricClasses{g};

            for m=1:length(matchingTechniques)
                matchingTechnique = matchingTechniques{m};
                
                for mc=1:length(matchingConstraints)
                    matchingConstraint = matchingConstraints{mc};
                    
                    sortedInd = computeNeighbors(imageDb, w, imgInfo, imgPopupInfo, ...
                        distancesPath, popupBasePath, maskDistancesPath, ...
                        colorSpace, colorSpaceInd, geometricClass, matchingTechnique, matchingConstraint);

                    if sortedInd ~= 0
                        titleStr = '';
                        outputDir = fullfile(outputBasePath, sprintf('%s_%dclasses_%s_%s', ...
                            colorSpace, length(geometricClass), matchingTechnique, matchingConstraint));
                        [m,m,m] = mkdir(outputDir); %#ok
                        fileStr = fullfile(outputDir, sprintf('%s.jpg', fileName));

                        doSave = 1;
                        doDisplay = 0;
                        displayNearestNeighborsMontage(imageDb, origImagesPath, img, sortedInd, K, ...
                            titleStr, fileStr, doSave, doDisplay);
                    end
                end
            end
        end
    end
end


%% Compute the distances
function sortedInd = computeNeighbors(imageDb, imageDbWeights, imgInfo, imgPopupInfo, ...
    distancesPath, popupBasePath, maskDistancesPath, ... 
    colorSpace, colorSpaceInd, geometricClass, matchingTechnique, matchingConstraint)

% store the weights (for normalization)
imgWeight = zeros(length(geometricClass), 1); % one for each type
weightedDist = zeros(1, length(imageDb));

for t=1:length(geometricClass)
    class = geometricClass{t};

    xmlDistPath = fullfile(distancesPath, sprintf('%s_%s', class, colorSpace), imgInfo.file.folder, imgInfo.file.filename);
    imgDistInfo = loadXML(xmlDistPath);

    distJointPath = fullfile(distancesPath, sprintf('%s_%s', class, colorSpace), imgInfo.file.folder, imgDistInfo.distances.(class).(colorSpace).joint.filename);
    load(distJointPath);

    % also load the corresponding histogram to get the weight
    histJointPath = fullfile(popupBasePath, imgPopupInfo.file.folder, imgPopupInfo.illContext(colorSpaceInd).(class).joint.filename);
    load(histJointPath);
    imgWeight(t) = sum(histoJoint(:)); %#ok
    
    if strcmp(matchingTechnique, 'weightedHisto')
        weightedDist = weightedDist + imgWeight(t) .* distancesJoint;
    elseif strcmp(matchingTechnique, 'averageHisto')
        weightedDist = weightedDist + distancesJoint;
    else
        fprintf('Unsupported matching technique: %s', matchingTechnique);
        sortedInd = 0; return;
    end
end

% normalize
weightedDist = weightedDist ./ sum(imgWeight);

if strcmp(matchingConstraint, 'noConstraint')
    indGood = 1:length(imageDb);
    
elseif strcmp(matchingConstraint, 'geometricRatio')
    % keep only those with similar ratios
    totWeights = zeros(length(geometricClass), length(imageDb));
    for t=1:length(geometricClass)
        totWeights(t,:) = imageDbWeights.(geometricClass{t}).(colorSpace).weightsJoint;
    end
    imgWeightNorm = imgWeight ./ sum(imgWeight);
    totWeightsNorm = totWeights ./ repmat(sum(totWeights), length(geometricClass), 1);
    diff=abs(repmat(imgWeightNorm, 1, length(imageDb)) - totWeightsNorm);

    threshRatio = 0.1;
    if length(geometricClass) == 2
        indGood = find(diff(1,:) < threshRatio & diff(2,:) < threshRatio);
    elseif length(geometricClass) == 3
        indGood = find(diff(1,:) < threshRatio & diff(2,:) < threshRatio & diff(3,:) < threshRatio);
    end
    
elseif strcmp(matchingConstraint, 'geometricLayout')
    % keep only images with similar geometric layout
    maskDist = zeros(1, length(imageDb));
    for t=1:length(geometricClass)
        xmlMaskPath = fullfile(maskDistancesPath, geometricClass{t}, imgInfo.file.folder, imgInfo.file.filename);
        imgMaskInfo = loadXML(xmlMaskPath);
        load(fullfile(maskDistancesPath, geometricClass{t}, imgInfo.file.folder, imgMaskInfo.distances.(geometricClass{t})));
        maskDist = maskDist + imgWeight(t) .* distances;
    end
    % normalize
    maskDist = maskDist ./ sum(imgWeight);

    [sortedDistMask, sortedIndMask] = sort(maskDist);
    sortedIndMask = sortedIndMask(sortedDistMask >= 0);
    sortedDistMask = sortedDistMask(sortedDistMask >= 0);

    threshDistMask = 0.1;
    distMin = sortedDistMask(floor(length(imageDb) * threshDistMask));
    indGood = sortedIndMask(sortedDistMask <= distMin);
else
    fprintf('Unsupported constraint: %s', matchingConstraint);
    sortedInd = 0; return;
end

% sort the weighted distances
[sortedDist, sortedInd] = sort(weightedDist(indGood));

% keep only the non-negative distances
sortedInd = sortedInd(sortedDist >= 0);
% sortedDist = sortedDist(sortedDist >= 0);

sortedInd = indGood(sortedInd);
function demoColorCompatibility
% Runs the color compatibility code on one image.
%
%   demoColorCompatibility
%
% This will first compute a realism score for the image, according to the
% algorithm presented in the ICCV'07 paper. 
% 
% The realism score printed is between 0 (highly realistic) and 1 (highly
% unrealistic). 
%
% It then recolors the object to try to make the image look more
% realistic, according to the recoloring algorithm in the ICCV'07 paper. 
% 
% ----------
% Jean-Francois Lalonde

%% Choose either option: (comment out the other)
imgName = 'image_004895';
recolorGlobal = true;

% imgName = 'image_002954';
% recolorGlobal = false;

%% User parameters (from ICCV'07)

% number of bins in color histogram
nbColorBins = 50;

% number of nearest neighbors to retrieve from the database
k = 50; 

% threshold on distance to objects in the database to determine whether the
% global or local measure should be used
maxDistance = 0.35; 

% blend between using color and texton distance
alpha = 0.75;

% sigma controls the amount of shift applied to each cluster (the larger
% sigma, the larger shift). 
recolorSigma = 50;

%% Setup paths 
imgPath = fullfile('data', 'images', sprintf('%s.jpg', imgName));
objMaskPath = fullfile('data', 'images', sprintf('%s.mat', imgName));

imageDbPath = 'http://balaton.graphics.cs.cmu.edu/jlalonde/colorStatistics/Images';

dbPath = fullfile('data', 'db');

nbTextonClusters = 1000;
clusterCentersPath = fullfile('data', sprintf('clusterCentersTest_%d.mat', nbTextonClusters));

colorConcatHistPath = fullfile(dbPath, 'concatHisto');
textonConcatHistPath = fullfile(dbPath, 'concatHistoTextons');

%% Load image information
img = imread(imgPath);
load(objMaskPath, 'objMask');

%% Load object database information
load(fullfile('data', 'indActiveLab_50.mat'));

%% Load texton information

% create filter bank from parameters
numOrient = 8;
startSigma = 1;
numScales = 2;
scaling = 1.4;
elong = 2;
filterBank = fbCreate(numOrient, startSigma, numScales, scaling, elong);

% load cluster centers
load(clusterCentersPath, 'clusterCenters');

%% Compute histograms
[textonObjHist, textonBgHist, colorObjHist, colorBgHist] = ...
    computeColorAndTextonHistograms(img, objMask, filterBank, clusterCenters, ...
    nbColorBins, indActiveLab);

%% Find k-nearest neighbors in the database
% Distance measure = 0.75*color + 0.25*texture on objects
% Use distance on background as realism measure
[realismScore, indGlobal, bgDist] = computeGlobalRealismScore(colorConcatHistPath, ...
    textonConcatHistPath, colorObjHist, textonObjHist, colorBgHist, textonBgHist, ...
    alpha, k);

%% Decide whether to use the local or global measure for evaluating realism
if realismScore > maxDistance
    % we didn't find a good object. Rely on the local measure.
    realismScore = alpha*chisq(colorBgHist, colorObjHist) + ...
        (1-alpha)*chisq(textonBgHist, textonObjHist);
end

fprintf('Realism score: %.2f\n', realismScore);

%% Re-color the object according to either
% 1. background in the same image 
% 2. background in the nearest-neighbor image 
  
if recolorGlobal
    % retrieve the best-matching background   
    [m,mind] = min(bgDist);
    
    load(fullfile('data/db/', 'objectDb.mat'), 'objectDb');
    objInfo = objectDb(mind).document;
    
    globalImgPath = fullfile(imageDbPath, objInfo.image.folder, ...
        objInfo.image.filename);
%     globalImgPath = '/home/user/disk/IH/baselines/lalonde/mycode/demo/data/images/image_002954.jpg';
    bgImg = im2double(imread(globalImgPath));
    
    % build the mask
    xPoly = str2double({objInfo.object.polygon.pt(:).x});
    yPoly = str2double({objInfo.object.polygon.pt(:).y});
    bgMask = poly2mask(xPoly, yPoly, size(bgImg, 1), size(bgImg, 2));
    
else
    % set to empty. recolorImage will use img and ~objMask internally.
    bgImg = []; bgMask = [];
end

%% Recolor the image
imgRecolored = recolorImage(img, objMask, bgImg, bgMask, ...
    'UseLAB', 1, 'Display', 0, 'Sigma', recolorSigma);
figure(1); clf;
subplot 121; imshow(img); title('Original image');
subplot 122; imshow(imgRecolored); title('Recolored image');

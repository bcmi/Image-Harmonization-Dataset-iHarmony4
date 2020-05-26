%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function replaceObjectsFromImage
% 
% Input parameters:
%
% Output parameters:
% 
% Requires:
%  This function requires data pre-computed by the following functions:
%  - doExtractObjectsMasks
%  - groupKeywordMasks
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function replaceObjectsFromImage(objectDb, topKeywords, topIndices)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths
addpath ../;
setPath;

% define the input and output paths
basePath = '/nfs/hn21/projects/labelmeSubsampled/';
imagesBasePath = fullfile(basePath, 'Images');
dbBasePath = fullfile(basePath, 'Annotation');

% rootPath = '/nfs/hn01/jlalonde/results/colorStatistics';
rootPath = '/usr2/home/jlalonde/results/colorStatistics/iccv07';

databasesPath = fullfile(rootPath, 'databases');
objectDbPath = fullfile(rootPath, 'objectDb');
maskStackPath = fullfile(databasesPath, 'maskStacks');

% Size of the mask 
maskWidth = 128;

% Size of the resulting image
imageSize = 256;

% Load an image from labelme
imDir = 'static_barcelona_street_city_outdoor_2005';
imName = 'img_0295';

a = loadXML(fullfile(dbBasePath, imDir, sprintf('%s.xml', imName)));
imgInfo = a.annotation;

origBgImg = imread(fullfile(imagesBasePath, imDir, sprintf('%s.jpg', imName)));
[hB,wB,d] = size(origBgImg); %#ok

%% Load object database and indices
if nargin == 0
    fprintf('Loading object database...\n');
    load(fullfile(databasesPath, 'objectDb.mat'));

    fprintf('Loading indices...\n');
    load(fullfile(databasesPath, 'keywordIndices.mat'));
end

%% Filter the objects based on their number of vertices (within a single keyword)

% Get the number of vertices for each object in the database
polygons = convertPolygonsFromXML(objectDb);
nbVertices = cellfun(@(x) size(x,1), polygons);

indicesToKeep = cell(1, length(topKeywords));
for i=1:length(topKeywords)
    indKeyword = topIndices{i};
    
    % only keep the objects which have enough vertices
    minNbVertices = prctile(nbVertices(indKeyword), 25);

    % modify the topIndices to keep only those objects
    indicesToKeep{i} = nbVertices(indKeyword) > minNbVertices;
    topIndices{i} = indKeyword(indicesToKeep{i});
end
    
%% Get the indices
% Reshape the database in the order corresponding to the indices
ind = [topIndices{:}];
objectDbReordered = objectDb(ind);

% Build a keyword for each object
keywords = {};
for i=1:length(topKeywords)
    t = repmat({topKeywords{i}}, 1, length(topIndices{i}));
    keywords = {keywords{:} t{:}};
end 

%% Resize image
% Compute original aspect ratio and keep it to avoid weird distorsions that might affect the result
% origRatio = str2double(imgInfo.image.origSize.width) / str2double(imgInfo.image.origSize.height);
origRatio = wB / hB;

if origRatio > 1
    imageW = imageSize .* origRatio;
    imageH = imageSize;
else
    imageW = imageSize;
    imageH = imageSize ./ origRatio;
end

imageW = round(imageW);
imageH = round(imageH);

% Resize the background image
bgImg = imresize(origBgImg, [imageH imageW], 'nearest');
resultImg = bgImg;

%% Loop over all the objects in the image
for i = 1:length(imgInfo.object)

    % get the keyword (call filterKeyword)
    keyword = filterKeyword(imgInfo.object(i).name);
    
    maskFile = fullfile(maskStackPath, sprintf('%s_stack.mat', keyword));
    
    if ~exist(maskFile, 'file')
        fprintf('No pre-computed mask stack for keyword %s, skipping...\n', keyword);
        continue;
    end
    
    % load up the corresponding mask stack
    load(maskFile);

    % get the mask (build it from the annotation)
    polygon = getPoly(imgInfo.object(i).polygon);
    polygon = polygon .* repmat([imageSize / wB, imageSize / hB], size(polygon, 1), 1);

    mask = poly2mask(polygon(:,1), polygon(:,2), imageSize, imageSize);

    % Now shift the mask so that the polygon's bounding box is centered
    center = min(polygon) + (max(polygon) - min(polygon))./2;
    shift = [imageSize/2 imageSize/2] - center;
    mask = circshift(mask, fix([shift(2) shift(1)]));

    % resize the mask to the correct size
    mask = imresize(mask, [maskWidth maskWidth], 'nearest'); %#ok

    %% Find the nearest neighbor (second because the first one will be itself)
    % compute the ssd to each mask in the stack
    indKeyword = find(strcmp(topKeywords, keyword));
    indToKeep = indicesToKeep{indKeyword};

    maskStack = maskStack(:,:,indToKeep); %#ok
    maskIndices = maskIndices(indToKeep); %#ok

    sqDist = sum(sum((repmat(mask, [1 1 size(maskStack, 3)]) - maskStack).^2, 1), 2);
    sqDist = squeeze(sqDist);

    [sortedDist, sortedInd] = sort(sqDist);
    
    % show top matches
%     montage(permute(maskStack(:,:,sortedInd(1:12)), [1 2 4 3]));

    % retrieve the corresponding object's index
    j = 1;
    minInd = find(ind == maskIndices(sortedInd(1)));

    % retrieve the nearest object's information
    nearestObjInfo = objectDbReordered(minInd).document;

    while strcmp(nearestObjInfo.image.folder, imgInfo.folder) && strcmp(nearestObjInfo.image.filename, imgInfo.filename)
        j = j + 1;
        minInd = find(ind == maskIndices(sortedInd(j)));
        nearestObjInfo = objectDbReordered(minInd).document;
    end

    %% Load and resize the nearest object's image
    origObjImg = imread(fullfile(imagesBasePath, nearestObjInfo.image.folder, nearestObjInfo.image.filename));
    [hO,wO,d] = size(origObjImg); %#ok
    objImg = imresize(origObjImg, [imageH imageW], 'nearest');

    %% Generate the composite

    % Load and resize the polygon to match the new size
    bgPoly = getPoly(imgInfo.object(i).polygon);
    bgPoly = bgPoly .* repmat([imageW / wB, imageH / hB], size(bgPoly, 1), 1);
    bgPolyCenter = min(bgPoly) + (max(bgPoly) - min(bgPoly))./2;

    % Load and resize the matching object's polygon to match the new size
    objPoly = getPoly(nearestObjInfo.object.polygon);
    objPoly = objPoly .* repmat([imageW / wO, imageH / hO], size(objPoly, 1), 1);
    objPolyCenter = min(objPoly) + (max(objPoly) - min(objPoly))./2;

    % re-center the polygon at the background's polygon center
    transPoly = fix(bgPolyCenter - objPolyCenter);
    dstPoly = objPoly + repmat((transPoly), size(objPoly, 1), 1);

    % Shift the object's image
    objImg = circshift(objImg, [transPoly(2) transPoly(1) 0]);

    % Apply simple feathering
    objMask = poly2mask(dstPoly(:,1), dstPoly(:,2), imageH, imageW);

    seRadius = 3;
    seErode = strel('disk', seRadius);
    objErode = double(imerode(objMask, seErode));

    distObj = bwdist(objErode);
    distBg = bwdist(ones(imageH, imageW) - objMask);

    alphaMask = ones(imageH, imageW) - distObj ./ (distObj + distBg);

    % Composite the image
    resultImg = uint8(double(objImg) .* repmat(alphaMask, [1 1 3]) + double(resultImg) .* (1-repmat(alphaMask, [1 1 3])));

    %% Display
    fprintf('Keyword: %s, Object name: %s\n', keyword, nearestObjInfo.object.name);
    figure(1), imshow(resultImg);
    figure(2), imshow(bgImg);
    pause;

end



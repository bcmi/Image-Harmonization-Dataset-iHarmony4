% function testTextonMatching
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load up images
addpath ../;
setPath;

imagesBasePath = '/nfs/hn21/projects/labelmeSubsampled/Images';
dbBasePath = '/nfs/hn21/projects/labelmeSubsampled/Annotation';
popupBasePath = '/nfs/hn25/labelmePopup/';

imageDbPath = '/nfs/hn01/jlalonde/results/colorStatistics/imageDb';

% Select source and target images, along with objects within them
% imgSrcPath = fullfile('30may05_static_street_cambridge', 'p1010685');
imgSrcPath = fullfile('30may05_static_street_cambridge', 'p1010687');
% imgTgtPath = fullfile('30may05_static_street_cambridge', 'p1010678');
imgTgtPath = fullfile('static_barcelona_street_city_outdoor_2_2005', 'img_0506');
% imgTgtPath = fullfile('nov6_static_outdoor', 'img_0476');
% imgTgtPath = imgSrcPath;
% imgSrcPath = imgTgtPath;

imgSrcPath = fullfile('spatial_envelope_256x256_static_8outdoorcategories', 'mountain_sharp33');
imgTgtPath = fullfile('spatial_envelope_256x256_static_8outdoorcategories', 'mountain_nat67');

imgSrcInfo = loadXML(fullfile(dbBasePath, sprintf('%s.xml', imgSrcPath)));
imgTgtInfo = loadXML(fullfile(dbBasePath, sprintf('%s.xml', imgTgtPath)));

imgSrc = imread(fullfile(imagesBasePath, sprintf('%s.jpg', imgSrcPath)));
imgTgt = imread(fullfile(imagesBasePath, sprintf('%s.jpg', imgTgtPath)));

% Get the superpixel information
imgSrcPopupInfo = loadXML(fullfile(popupBasePath, sprintf('%s.xml', imgSrcPath)));
imgTgtPopupInfo = loadXML(fullfile(popupBasePath, sprintf('%s.xml', imgTgtPath)));

% Get the object's outline
objInfo = imgSrcInfo.annotation.object(4);

% Get the source and target texton map
imgDbSrcInfo = loadXML(fullfile(imageDbPath, sprintf('%s.xml', imgSrcPath)));
imgDbTgtInfo = loadXML(fullfile(imageDbPath, sprintf('%s.xml', imgTgtPath)));

load(fullfile(imageDbPath, imgDbSrcInfo.file.folder, imgDbSrcInfo.univTextons.textonMap));
textonMapSrc = textonMap;
load(fullfile(imageDbPath, imgDbTgtInfo.file.folder, imgDbTgtInfo.univTextons.textonMap));
textonMapTgt = textonMap;

% Extract the selected object's polygon
objPoly = getPoly(objInfo.polygon);
objMask = poly2mask(objPoly(:,1), objPoly(:,2), size(imgSrc,1), size(imgSrc,2));

% Show everything we have loaded so far
figure(1);
subplot(2,2,1), imshow(imgSrc), hold on, plot(objPoly(:,1), objPoly(:,2), 'LineWidth', 2), title('Source image');
subplot(2,2,2), imshow(imgTgt), title('Target image');
subplot(2,2,3), imagesc(textonMapSrc), title('Source image textons'), axis off; 
subplot(2,2,4), imagesc(textonMapTgt), title('Target image textons'), axis off;
drawnow;

% threshold
t = 0.4;

%% Compute the texton histogram of the selected object
global objTextonHisto;

% get the histogram, normalize it
objTextonHisto = myHistoND(textonMapSrc(objMask>0), 1000, 1, 1000);
objTextonHisto = objTextonHisto ./ sum(objTextonHisto(:)); 

%% First approach: Divide up the target image into 8x8 blocks
if 0
nbBlocks = 20;
blockDist = zeros(nbBlocks);
blockImg = zeros(size(imgTgt, 1), size(imgTgt, 2));

imageDivi = floor(size(imgTgt,1) ./ nbBlocks);
imageDivj = floor(size(imgTgt,2) ./ nbBlocks);

for i=1:nbBlocks
    for j=1:nbBlocks
        % get the block's textons
        blockIndi = (i-1)*imageDivi+1:i*imageDivi;
        blockIndj = (j-1)*imageDivj+1:j*imageDivj;
        block = textonMapTgt(blockIndi, blockIndj);
        % compute the histogram
        blockHisto = myHistoND(block(:), 1000, 1, 1000);
        blockHisto = blockHisto ./ sum(blockHisto(:));
        % compute and store the distance
        blockDist(i,j) = chisq(blockHisto, objTextonHisto);
        
        blockImg(blockIndi, blockIndj) = blockDist(i,j);
    end
end

% threshold the distance and show the blocks retained
ind = find(repmat(blockImg, [1 1 3]) < t);
blockThreshold = zeros(size(imgTgt,1), size(imgTgt,2), 3, 'uint8');
blockThreshold(ind) = imgTgt(ind);

% show the results
figure(2);
subplot(3,1,1), imshow(imgTgt);
subplot(3,1,2), imagesc(blockImg, 'CDataMapping', 'scaled'), set(gca, 'CLim', [0 1]), colorbar, axis image off;
subplot(3,1,3), imshow(blockThreshold);
end
%% Second approach: Superpixels
if 0
spPath = fullfile(popupBasePath, imgDbTgtInfo.file.folder, imgTgtPopupInfo.superpixel.filename);
load(spPath);

segmentDist = zeros(1, segStruct.nseg);
for i=1:segStruct.nseg
    % get the segment's textons
    indSegment = segStruct.segimage == i;
    segmentTextons = textonMapTgt(indSegment);
    
    % compute the histogram
    segmentHisto = myHistoND(segmentTextons(:), 1000, 1, 1000);

    % compute and store the distance
    segmentDist(i) = chisq(segmentHisto, objTextonHisto);
end

segmentImg = segmentDist(segStruct.segimage);

ind = find(repmat(segmentImg, [1 1 3]) < t);
segmentThreshold = zeros(size(imgTgt), 'uint8');
segmentThreshold(ind) = imgTgt(ind);

% threshold the distance and show the segments retained
figure(3);
subplot(3,1,1), imshow(imgTgt);
subplot(3,1,2), imagesc(segmentImg, 'CDataMapping', 'scaled'), set(gca, 'CLim', [0 1]), colorbar, axis image off;
subplot(3,1,3), imshow(segmentThreshold);
end
%% Third approach: Sliding windows
windowHalfSize = 20;

% imgTmp = imgTgt;
% imgTgt = imresize(imgTgt, 0.5);

[r,c,d] = size(imgTgt);
windowDist = ones(r,c);

fprintf('Computing sliding windows...');tic;
for i=1+windowHalfSize:r-windowHalfSize
    
    j = 1+windowHalfSize;
    indWindowi = i-windowHalfSize:i+windowHalfSize;
    indWindowj = j-windowHalfSize:j+windowHalfSize;
    
    window = textonMapTgt(indWindowi, indWindowj);
    windowHisto = histc(window(:), 1:1000);
    windowDist(i, j) = chisq(windowHisto, objTextonHisto);
    
    for j=1+windowHalfSize+1:c-windowHalfSize
        windowInc = textonMapTgt(indWindowi, j+windowHalfSize);
        windowDec = textonMapTgt(indWindowi, j-windowHalfSize-1);
        
        % compute the histogram
        windowIncHisto = histc(windowInc(:), 1:1000);
        windowDecHisto = histc(windowDec(:), 1:1000);
        windowHisto = windowHisto + windowIncHisto - windowDecHisto;
        
        % compute and store the distance
        windowDist(i,j) = chisq(windowHisto, objTextonHisto);
    end
end
fprintf('done in %fs\n', toc);

% imgTgt = imgTmp;
% reinterpolate the distances

% threshold the distance and show the blocks retained
ind = find(repmat(windowDist, [1 1 3]) < t);
windowThreshold = zeros(size(imgTgt,1), size(imgTgt,2), 3, 'uint8');
windowThreshold(ind) = imgTgt(ind);

% show the results
figure(3);
subplot(3,1,1), imshow(imgTgt);
subplot(3,1,2), imagesc(windowDist, 'CDataMapping', 'scaled'), set(gca, 'CLim', [0 1]), colorbar, axis image off;
subplot(3,1,3), imshow(windowThreshold);


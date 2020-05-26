%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function testColorDistance
% 
% Input parameters:
%
% Output parameters:
%
%    
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function testColorDistance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setup paths and load stuff
addpath ../;
setPath;

dbPath = '/nfs/hn01/jlalonde/results/colorStatistics/dataset/combinedDb/';
imagesDbPath = fullfile(dbPath, 'Images');
annDbPath = fullfile(dbPath, 'Annotation');

filename = 'image_110638';

imgPath = fullfile(imagesDbPath, sprintf('%s.jpg', filename));
annPath = fullfile(annDbPath, sprintf('%s.xml', filename));

img = imread(imgPath);
imgInfo = loadXML(annPath);

nbPixelsDistances = 500;

%% Compute pairwise color distances over the entire image
imgVector = reshape(img, size(img,1)*size(img,2), size(img,3));

x = 1:5:400;
nbIter = 20;

accHistoRgb = computeColorDistanceHistogram(imgVector, x, nbIter, nbPixelsDistances);
figure(1), bar(x, accHistoRgb), xlim([0 max(x)]), title('RGB distances histogram', 'FontSize', 18);
set(gca, 'FontSize', 18);

%% Try in Lab
imgLab = rgb2lab(img);
imgVectorLab = reshape(imgLab, size(img,1)*size(img,2), size(img,3));

x = 1:2:150;
nbIter = 20;

accHistoLab = computeColorDistanceHistogram(imgVectorLab, x, nbIter, nbPixelsDistances);
figure(2), bar(x, accHistoLab), xlim([0 max(x)]), title('Lab distances histogram');

figure(3), displayColors(imgVectorLab, imgVector);

%% Try just ab channels
imgVectorAb = imgVectorLab(:,2:3);

x = 1:2:150;
nbIter = 20;

accHistoAb = computeColorDistanceHistogram(imgVectorAb, x, nbIter, nbPixelsDistances);
figure(4), bar(x, accHistoAb), xlim([0 max(x)]), title('AB distances histogram');
